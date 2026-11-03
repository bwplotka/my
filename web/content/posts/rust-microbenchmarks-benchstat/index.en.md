---
title: "Bringing Go's benchstat Workflow to Rust with benchfmt-rs"
date: "2026-11-03"
weight: 1
categories:
- rust
- go
- efficiency
featuredImage: "/og-images/benchfmt-rs.png"
---

> **TL;DR:** I built [`benchfmt-rs`](https://github.com/bwplotka/benchfmt-rs) to bring Go's [`benchstat`](https://pkg.go.dev/golang.org/x/perf/cmd/benchstat) workflow to Rust, with `/key=value` projections, zero-dependency `B/op` and `allocs/op` heap tracking, `pprof` profiles, and a [`Criterion`](https://crates.io/crates/criterion) converter. Benchmarking `varint` and [Prometheus Remote Write 2.0](https://prometheus.io/docs/specs/prw/remote_write_spec_2_0/) decoding across Go and Rust surfaced three practical lessons:
> * **Rust won on speed, Go won on `B/op`.** Rust decoded varints `42.6%` faster and Remote Write 2.0 `17.7%` faster with `14.6%` fewer allocations, yet requested **`31.0%` more heap bytes** because [`prost`](https://crates.io/crates/prost) repeatedly reallocates un-sized `Vec` buffers (`88.4%` of allocated bytes in `go tool pprof`).
> * **`B/op` measures allocator churn, not RSS.** Allocating `2.00 GiB` across `1,000` Rust decodes peaked at just `4.21 MiB` RSS because freed chunks were recycled every iteration, compared to `1.29 MiB` per batch when retained in memory.
> * **Wall-clock `ns/op` hides GC overhead.** Under `/usr/bin/time -v`, Go's concurrent garbage collector burned extra CPU and memory on background threads, meaning Rust used **`1.9x` to `3.2x` less total CPU core-time** and **`3.8x` to `4.4x` less RAM** per request.

Recently, I've been working on a few Rust projects in different areas at Google and [OSS](https://github.com/prometheus/expfmt-rs), mostly because I think Rust has a potential in this AI era:
* It has an extreme amount of compile-time verification (TODO link) including extended memory safety checks (TODO link) -- ideal when you generate code.
* It takes ages and is frustrarting to program in (sorry!) -- AI writes codes nowadays, so it doesn't matter -- it just has to be readable for reviews and it's good enough at that.
* It has greate columnar storage library ecosystem
* It does not have GC, gives more flexibility on memory allocations and it's generally faster!

I came to Rust after years of writing performance-sensitive Go in [Prometheus](https://prometheus.io/), [Thanos](https://thanos.io/) and more. I even wrote a ["Efficient Go" book](/book) teaching about those.  For me, much of Rust's performance story is a really good, until... you want to run an **A/B micro-benchmarks**. Perhaps I was spoiled by the Go benchmarking ecosystem with a standard [`benchstat`](https://pkg.go.dev/golang.org/x/perf/cmd/benchstat) sitting at the center of everyone's Go workflow (see why it's amazing in my previous [post](/2024/go-microbenchmarks-benchstat/).

Like, how Rust can claim to be more "performance" oriented, yet it's official Rust benchmarking misses:
* standard for case comparsion projections
* standard heap allocation measurements
* standard pprof supports
* Mann-Whitney U p-values reliability scores.

So I asked myself what if we could have a `benchstat` like output for Rust microbenchmarks. Wouldn't it be better? and allow those fun Go vs Rust benchmarks and learnings?

Here we are -- I built [`benchfmt-rs`](https://github.com/bwplotka/benchfmt-rs) a zero-dependency Rust benchmark runner, with the thread-local heap allocation counter, `pprof` profiler integration and the same CLI surface as `go test -bench`. For those who don't trust new benchmarking runtime (you shouldn't from the start!), there's also a `Criterion` and `libtest` converter that emits Go's `benchfmt` format directly.

In this blog post I want to do a fun exercise -- we will do a microbenchmarking exercise on the same pieces of code in Go and Rust and compare those, using different benchmarking frameworks in Rust. We might learn something new on the way (I did when building this!). Enjoy!

## Picking two workloads, varints and Prometheus Remote Write

Comparing only one kind of benchmark hides half the trade-offs. A tight CPU loop with zero heap activity behaves very differently from a wire protocol decoder that decompresses payloads and materializes thousands of nested structs and strings. Let's benchmark both.

1. **`DecodeVarints`.** A 36-line unsigned LEB128 varint stream decoder. Varints are the integer encoding underneath Protocol Buffers. Our fixture `varints_2000.bin` is `4,798` bytes and packs `2,000` `uint64` values mixing 1-byte symbol indices, 2-byte bucket offsets, 4-byte deltas, and 6-byte millisecond Unix timestamps. The function writes into a preallocated `2,000`-element slice with zero heap allocations.
2. **`DecodeRemoteWrite`.** A full HTTP request body decoder for [Prometheus Remote Write 1.0](https://prometheus.io/docs/concepts/remote_write_spec/) `prometheus.WriteRequest` and [Remote Write 2.0](https://prometheus.io/docs/concepts/remote_write_spec_2_0/) `io.prometheus.write.v2.Request`. Each operation takes a Snappy-block-compressed payload and unmarshals the full protobuf tree for batches of `200` and `2,000` series, where `2,000` matches Prometheus's default `max_samples_per_send`. Each `2,000`-series batch mixes `500` counters, `400` gauges, `100` classic 8-bucket histograms totaling `1,000` series, `100` native exponential histograms, `1,000` trace exemplars, and metric metadata.

Remote Write 1.0 repeats every label name and value string on every series. At `2,000` series, that payload is `1,399.6 KiB` uncompressed and `110.3 KiB` Snappy-compressed. Remote Write 2.0 interns all strings into a single `repeated string symbols` table at the top of the message and stores packed varint `labels_refs` indices per series. For the exact same `2,000` series, Remote Write 2.0 shrinks the payload to `244.9 KiB` uncompressed and `57.0 KiB` Snappy-compressed.

To keep the comparison honest, a deterministic Go generator writes the binary fixtures once into `testdata/` alongside a `manifest.json` file. That manifest records uncompressed byte sizes, series counts, sample counts, and an XOR checksum of all IEEE-754 sample bits, `56757976630294132` for the `2,000`-series batch. Unit tests in both Go and Rust assert that every decoder produces the exact manifest counts and checksums before we time anything.

## Implementing and running the Go benchmark

On the Go side, `DecodeVarints` writes straight into a caller-provided slice, with a fast path for single-byte values below `0x80`:

```go
func DecodeVarints(src []byte, dst []uint64) (int, error) {
	n := 0
	i := 0
	for i < len(src) {
		if n >= len(dst) {
			return n, ErrDstTooSmall
		}
		b := src[i]
		i++
		if b < 0x80 {
			dst[n] = uint64(b)
			n++
			continue
		}
		x := uint64(b & 0x7f)
		shift := uint(7)
		for {
			if i >= len(src) {
				return n, ErrUnexpectedEOF
			}
			b = src[i]
			i++
			x |= uint64(b&0x7f) << shift
			if b < 0x80 {
				break
			}
			shift += 7
			if shift >= 64 {
				return n, ErrOverflow
			}
		}
		dst[n] = x
		n++
	}
	return n, nil
}
```

## Benchmarking two workloads, varints and decoding Prometheus Remote Write 2 proto

Let's pick two example workloads we want to implement and benchmark in both Go and Rust. I am particularly curious about protobuf decoding performance, which. funny enough, is one of the main cost of running distributed systems these days, so let's try to decode our [new Remote Write 2 protocol](https://prometheus.io/docs/specs/prw/remote_write_spec_2_0/). However, protobuf generators have different maturity and trade-offs across languages, so let's also measure something simpler e.g. an example `varint` implementation:

1. **`DecodeVarints`.** A 36-line unsigned LEB128 varint stream decoder. Our fixture `varints_2000.bin` is `4,798` bytes and packs `2,000` `uint64` values mixing 1-byte symbol indices, 2-byte bucket offsets, 4-byte deltas, and 6-byte millisecond Unix timestamps. The function writes into a preallocated `2,000`-element slice with zero heap allocations.
2. **`DecodeRemoteWrite`.** A full HTTP request body decoder for [Remote Write 2.0](https://prometheus.io/docs/concepts/remote_write_spec_2_0/) `io.prometheus.write.v2.Request`. Each operation takes a Snappy-block-compressed payload and unmarshals the full protobuf tree for batches of `200` and `2,000` series, where `2,000` matches Prometheus's default `max_samples_per_send`. Each `2,000`-series batch mixes `500` counters, `400` gauges, `100` classic 8-bucket histograms totaling `1,000` series, `100` native exponential histograms, `1,000` trace exemplars, and metric metadata. Remote Write 2.0 interns all strings into a single `repeated string symbols` table at the top of the message and stores packed varint `labels_refs` indices per series, which shrinks the payload to `244.9 KiB` uncompressed and `57.0 KiB` Snappy-compressed.

To keep the comparison honest, a deterministic Go generator writes the binary fixtures once into `testdata/` alongside a `manifest.json` file. That manifest records uncompressed byte sizes, series counts, sample counts, and an XOR checksum of all IEEE-754 sample bits, `56757976630294132` for the `2,000`-series batch. Unit tests in both Go and Rust assert that every decoder produces the exact manifest counts and checksums before we time anything.

## Implementing and running the Go benchmark

On the Go side, `DecodeVarints` writes straight into a caller-provided slice, with a fast path for single-byte values below `0x80`:

```go
func DecodeVarints(src []byte, dst []uint64) (int, error) {
	n := 0
	i := 0
	for i < len(src) {
		if n >= len(dst) {
			return n, ErrDstTooSmall
		}
		b := src[i]
		i++
		if b < 0x80 {
			dst[n] = uint64(b)
			n++
			continue
		}
		x := uint64(b & 0x7f)
		shift := uint(7)
		for {
			if i >= len(src) {
				return n, ErrUnexpectedEOF
			}
			b = src[i]
			i++
			x |= uint64(b&0x7f) << shift
			if b < 0x80 {
				break
			}
			shift += 7
			if shift >= 64 {
				return n, ErrOverflow
			}
		}
		dst[n] = x
		n++
	}
	return n, nil
}
```

For `DecodeRemoteWrite`, we tune Go the way Prometheus runs in production rather than benchmarking slow `protoreflect` unmarshaling. We pair `github.com/golang/snappy`, which uses x86-64 assembly on `linux/amd64`, with [`vtprotobuf`](https://github.com/planetscale/vtprotobuf) and its generated `UnmarshalVT` decoder:

```go
func DecodeRemoteWriteV2(compressed []byte) (*writev2.Request, error) {
	raw, err := snappy.Decode(nil, compressed)
	if err != nil {
		return nil, err
	}
	req := &writev2.Request{}
	if err := req.UnmarshalVT(raw); err != nil {
		return nil, err
	}
	return req, nil
}
```

In `benchmark_test.go`, we follow Go's `/key=value` sub-benchmark naming convention, such as `proto=v1/samples=2000/lang=go`, so `benchstat` can project across `/lang` or `/proto` later. We also call `b.SetBytes` with the compressed byte length and `b.ReportAllocs` before `for b.Loop()`. Let's run `6` epochs of `2s` each at `-cpu 2` on our 24-core Intel Xeon 2.20GHz Linux workstation using Go 1.26.8 and Rust 1.99.1:

```bash
go test -run '^$' -bench '^BenchmarkDecode' \
    -benchtime 2s -count 6 -cpu 2 -timeout 999m -benchmem \
| tee results/go.txt
```

Here is one epoch per case from `results/go.txt`:

```text
goos: linux
goarch: amd64
pkg: github.com/bwplotka/benchmarks/benchmarks/rust-go-decode
cpu: Intel(R) Xeon(R) CPU @ 2.20GHz
BenchmarkDecodeVarints/samples=2000/lang=go-2                   279861      8514 ns/op   563.52 MB/s        0 B/op        0 allocs/op
BenchmarkDecodeRemoteWrite/proto=v1/samples=200/lang=go-2         2718    897577 ns/op    13.96 MB/s   628370 B/op    10200 allocs/op
BenchmarkDecodeRemoteWrite/proto=v1/samples=2000/lang=go-2         244   9707059 ns/op    11.63 MB/s  6248869 B/op   101828 allocs/op
BenchmarkDecodeRemoteWrite/proto=v2/samples=200/lang=go-2         8467    264321 ns/op    31.43 MB/s   195296 B/op     2189 allocs/op
BenchmarkDecodeRemoteWrite/proto=v2/samples=2000/lang=go-2         976   2448633 ns/op    23.84 MB/s  1643970 B/op    19297 allocs/op
```

Even before touching Rust, those five lines tell a story. Across all 6 epochs, `DecodeVarints` runs at a median of `8,536 ns/op`, or `8.54 µs`, with `0 B/op` and `0 allocs/op`. Remote Write 1.0 at `2,000` series takes a median of `10,061,889 ns/op`, or `10.06 ms`, allocating `6,248,868 B/op`, or `5.96 MiB`, across `101,828 allocs/op`. Switching to Remote Write 2.0 drops latency by 75% to `2,470,127 ns/op`, or `2.47 ms`, and cuts allocations by 81% to `19,297 allocs/op` and `1,643,970 B/op`, or `1.57 MiB`.

## Implementing in Rust with Criterion and spotting the gaps

Now let's port both decoders to Rust. `decode_varints` in `src/varints.rs` mirrors the Go loop line for line. For Remote Write, we pair the standard [`snap`](https://crates.io/crates/snap) crate with [`prost`](https://crates.io/crates/prost) compile-time generated `Message` structs:

```rust
pub fn decode_remote_write_v2(compressed: &[u8]) -> Result<proto::v2::Request, String> {
    let raw = snap::raw::Decoder::new()
        .decompress_vec(compressed)
        .map_err(|e| e.to_string())?;
    proto::v2::Request::decode(raw.as_slice()).map_err(|e| e.to_string())
}
```

In the Rust ecosystem, [`Criterion`](https://crates.io/crates/criterion) is the default choice for stable-Rust microbenchmarking. Writing `benches/criterion_decode.rs` with the same `/key=value` benchmark IDs and `Throughput::Bytes` looks clean:

```rust
fn bench_varints(c: &mut Criterion) {
    let root = Path::new(env!("CARGO_MANIFEST_DIR")).join("testdata");
    let raw = fs::read(root.join("varints_2000.bin")).unwrap();
    let mut dst = vec![0u64; 2000];

    let mut group = c.benchmark_group("DecodeVarints");
    group.throughput(Throughput::Bytes(raw.len() as u64));
    group.bench_function("samples=2000/lang=rust", |b| {
        b.iter(|| {
            let n = decode_varints(black_box(&raw), black_box(&mut dst)).unwrap();
            assert_eq!(n, 2000);
            black_box(dst[n - 1]);
        });
    });
    group.finish();
}
```

Running `cargo bench --bench criterion_decode` prints:

```text
DecodeVarints/samples=2000/lang=rust
                        time:   [5.2789 µs 5.3369 µs 5.4014 µs]
                        thrpt:  [847.14 MiB/s 857.38 MiB/s 866.80 MiB/s]

DecodeRemoteWrite/proto=v1/samples=200/lang=rust
                        time:   [711.57 µs 720.70 µs 731.79 µs]
                        thrpt:  [16.325 MiB/s 16.576 MiB/s 16.789 MiB/s]

DecodeRemoteWrite/proto=v1/samples=2000/lang=rust
                        time:   [6.9950 ms 7.0558 ms 7.1501 ms]
                        thrpt:  [15.061 MiB/s 15.262 MiB/s 15.395 MiB/s]

DecodeRemoteWrite/proto=v2/samples=200/lang=rust
                        time:   [237.09 µs 238.48 µs 239.95 µs]
                        thrpt:  [33.017 MiB/s 33.220 MiB/s 33.414 MiB/s]

DecodeRemoteWrite/proto=v2/samples=2000/lang=rust
                        time:   [2.0712 ms 2.0831 ms 2.0968 ms]
                        thrpt:  [26.546 MiB/s 26.720 MiB/s 26.874 MiB/s]
```

Criterion is a thoughtful library, and its linear regression slope estimator works well for standalone Rust work. When you want Go-style `benchstat` workflows or cross-language comparisons, five concrete differences get in the way:

1. **Compile weight.** Pulling in `criterion`, even with `default-features = false`, brings in `clap`, `regex-automata`, `ciborium`, `oorandom`, `itertools`, `tinytemplate`, and `anes`, adding 42 transitive crates and ~19s to a cold `cargo bench` build.
2. **Binary `MiB/s` vs decimal `MB/s`.** Criterion formats `Throughput::Bytes` as binary `MiB/s`, `1,048,576` bytes per second, whereas Go's `testing.B.SetBytes` prints decimal `MB/s`, `1,000,000` bytes per second. Comparing `857.38 MiB/s` against Go's `563.52 MB/s` by eye silently introduces a `4.86%` unit error unless you switch to `Throughput::BytesDecimal` or recompute from raw nanoseconds and bytes.
3. **Linear-ramp sampling vs steady-state epochs.** Go's `testing.B` calibrates an iteration count `N` until one run hits `-benchtime` of `2s`, then executes `-count 6` independent runs at that fixed `N` for `benchstat`'s Mann-Whitney U rank-sum test. Criterion defaults to `Linear` sampling instead. After a 3-second warmup, it collects 100 samples of `[1d, 2d, ..., 100d]` iterations into `sample.json` and fits a slope through the origin.
4. **No heap allocation tracking.** Criterion reports wall-clock time and throughput, full stop. On `DecodeVarints` at `0 allocs/op`, that is fine. On `DecodeRemoteWrite`, we have no idea whether `prost` did 500 heap allocations or 500,000, or whether a refactor doubled heap churn.
5. **Pairwise baseline folders vs multi-dimensional tables.** Criterion compares `target/criterion/<id>/base` against `new`. You cannot take one run file and pivot `-col /proto` or `-col /lang` across Go and Rust.

## Converting Criterion output with the `benchfmt` CLI

If a Rust codebase already has Criterion benchmarks, rewriting them just to get a `benchstat` table is annoying. That is why `benchfmt-rs` ships a zero-dependency `benchfmt` CLI binary. It walks `target/criterion`, reads `benchmark.json` and `sample.json` directly, converts `Throughput::Bytes` into Go's decimal `MB/s`, and aggregates Criterion's 100 samples into `6` contiguous epochs via `--epochs 6` by default:

```bash
cargo install --git https://github.com/bwplotka/benchfmt-rs

benchfmt criterion target/criterion \
    --pkg github.com/bwplotka/benchmarks/benchmarks/rust-go-decode \
    --cpu 2 \
> results/rust_criterion.txt

benchstat -col /lang results/go.txt results/rust_criterion.txt
```

Without touching `benches/criterion_decode.rs`, `benchstat` immediately gives us a side-by-side Go vs Rust table:

```text
goos: linux
goarch: amd64
pkg: github.com/bwplotka/benchmarks/benchmarks/rust-go-decode
cpu: Intel(R) Xeon(R) CPU @ 2.20GHz
                                          │      go       │                rust                │
                                          │    sec/op     │   sec/op     vs base               │
DecodeVarints/samples=2000-2                 8.536µ ±  1%   5.364µ ± 5%  -37.16% (p=0.002 n=6)
DecodeRemoteWrite/proto=v1/samples=200-2     895.9µ ±  2%   717.9µ ± 3%  -19.87% (p=0.002 n=6)
DecodeRemoteWrite/proto=v1/samples=2000-2   10.062m ± 31%   7.008m ± 4%  -30.35% (p=0.002 n=6)
DecodeRemoteWrite/proto=v2/samples=200-2     271.4µ ±  3%   235.1µ ± 4%  -13.37% (p=0.002 n=6)
DecodeRemoteWrite/proto=v2/samples=2000-2    2.470m ±  5%   2.082m ± 1%  -15.72% (p=0.002 n=6)
geomean                                      552.7µ         420.9µ       -23.85%

                                          │      go       │                rust                 │
                                          │      B/s      │     B/s       vs base               │
DecodeVarints/samples=2000-2                536.1Mi ±  1%   853.2Mi ± 5%  +59.15% (p=0.002 n=6)
DecodeRemoteWrite/proto=v1/samples=200-2    13.34Mi ±  2%   16.64Mi ± 3%  +24.78% (p=0.002 n=6)
DecodeRemoteWrite/proto=v1/samples=2000-2   10.70Mi ± 24%   15.36Mi ± 4%  +43.52% (p=0.002 n=6)
DecodeRemoteWrite/proto=v2/samples=200-2    29.19Mi ±  3%   33.70Mi ± 4%  +15.44% (p=0.002 n=6)
DecodeRemoteWrite/proto=v2/samples=2000-2   22.53Mi ±  5%   26.74Mi ± 1%  +18.67% (p=0.002 n=6)
geomean                                     34.70Mi         45.57Mi       +31.31%

                                          │       go       │
                                          │      B/op      │
DecodeVarints/samples=2000-2                  0.000 ± 0%
DecodeRemoteWrite/proto=v1/samples=200-2    613.6Ki ± 0%
DecodeRemoteWrite/proto=v1/samples=2000-2   5.959Mi ± 0%
DecodeRemoteWrite/proto=v2/samples=200-2    190.7Ki ± 0%
DecodeRemoteWrite/proto=v2/samples=2000-2   1.568Mi ± 0%

                                          │      go       │
                                          │   allocs/op   │
DecodeVarints/samples=2000-2                 0.000 ± 0%
DecodeRemoteWrite/proto=v1/samples=200-2    10.20k ± 0%
DecodeRemoteWrite/proto=v1/samples=2000-2   101.8k ± 0%
DecodeRemoteWrite/proto=v2/samples=200-2    2.189k ± 0%
DecodeRemoteWrite/proto=v2/samples=2000-2   19.30k ± 0%
```

Notice that `benchstat` normalizes Go's decimal `MB/s` lines into binary `MiB/s` under `B/s` for both columns automatically once both files speak `benchfmt`. Rust is `37.16%` faster on `DecodeVarints` at `5,364 ns/op` vs `8,536 ns/op`, and `13.37%` to `30.35%` faster on `DecodeRemoteWrite`.

Look at the bottom half of that output, though. The `B/op` and `allocs/op` tables only have a `go` column because Criterion never recorded allocations. And if you inspect `results/rust_criterion.txt`, bucket 1 of `DecodeVarints` summed `24,888` iterations while bucket 6 summed `286,212` iterations because of Criterion's linear ramp, leaving `± 5%` variance on a deterministic pure-CPU loop.

## Native `benchfmt` runs with `benchfmt::Suite` and `CountingAlloc`

When writing new Rust benchmarks, we can skip Criterion altogether and use `benchfmt::Suite` in `benches/suite_decode.rs` with `harness = false` in `Cargo.toml`. By registering `CountingAlloc` as `#[global_allocator]`, every `alloc`, `alloc_zeroed`, and `realloc` increments a `const`-initialized `thread_local!` `Cell<(u64, u64)>` with zero atomic contention across threads and zero external crate dependencies by default:

```rust
use std::hint::black_box;

use benchfmt::{CountingAlloc, Suite};
use rust_go_decode::{decode_remote_write_v1, decode_remote_write_v2, decode_varints};

#[global_allocator]
static ALLOC: CountingAlloc = CountingAlloc::new();

fn main() {
    // ... read testdata fixtures ...
    let mut dst = vec![0u64; 2000];

    Suite::from_env("github.com/bwplotka/benchmarks/benchmarks/rust-go-decode")
        .with_alloc(&ALLOC)
        .bench("DecodeVarints/samples=2000/lang=rust", |b| {
            b.set_bytes(raw_varints.len() as u64);
            b.report_allocs();
            while b.keep_running() {
                let n = decode_varints(black_box(&raw_varints), black_box(&mut dst)).unwrap();
                assert_eq!(n, 2000);
                black_box(dst[n - 1]);
            }
        })
        // ... DecodeRemoteWrite v1 and v2 cases ...
        .run();
}
```

`Suite::from_env` accepts the exact same flags as `go test`:

```bash
cargo bench --bench suite_decode -- \
    -bench '^BenchmarkDecode' -benchtime 2s -count 6 -cpu 2 -benchmem \
| tee results/rust_suite.txt
```

First, let's check whether `benchfmt::Suite`, even with `CountingAlloc` enabled on every allocation, agrees with Criterion on timing:

```bash
benchstat criterion=results/rust_criterion.txt suite=results/rust_suite.txt
```

```text
                                                    │  criterion  │               suite               │
                                                    │   sec/op    │   sec/op     vs base              │
DecodeRemoteWrite/proto=v1/samples=2000/lang=rust-2   7.008m ± 4%   7.001m ± 2%       ~ (p=0.818 n=6)
DecodeRemoteWrite/proto=v1/samples=200/lang=rust-2    717.9µ ± 3%   732.3µ ± 1%       ~ (p=0.180 n=6)
DecodeRemoteWrite/proto=v2/samples=2000/lang=rust-2   2.082m ± 1%   2.033m ± 2%  -2.33% (p=0.015 n=6)
DecodeRemoteWrite/proto=v2/samples=200/lang=rust-2    235.1µ ± 4%   231.5µ ± 1%  -1.55% (p=0.004 n=6)
DecodeVarints/samples=2000/lang=rust-2                5.364µ ± 5%   4.902µ ± 2%  -8.60% (p=0.002 n=6)
geomean                                               420.9µ        411.7µ       -2.18%
```

On the multi-millisecond Remote Write benchmarks, Criterion and `benchfmt::Suite` agree within `0.1%` to `2.3%`, such as `7,001,455 ns/op` vs `7,007,879 ns/op` on `v1/2000`, while `Suite`'s steady-state `2s` epochs tighten worst-case variance across the suite from `± 4-5%` down to `± 1-2%`. On the `4.9 µs` `DecodeVarints` loop, `while b.keep_running()` runs `490,000` back-to-back iterations in a single tight loop rather than calling a closure across 100 short ramp batches, clocking `4,902 ns/op` vs `5,364 ns/op`.

Now let's run the full Go vs Rust comparison with `results/rust_suite.txt`:

```bash
benchstat -col /lang results/go.txt results/rust_suite.txt
```

```text
goos: linux
goarch: amd64
pkg: github.com/bwplotka/benchmarks/benchmarks/rust-go-decode
cpu: Intel(R) Xeon(R) CPU @ 2.20GHz
                                          │      go       │                rust                │
                                          │    sec/op     │   sec/op     vs base               │
DecodeVarints/samples=2000-2                 8.536µ ±  1%   4.902µ ± 2%  -42.56% (p=0.002 n=6)
DecodeRemoteWrite/proto=v1/samples=200-2     895.9µ ±  2%   732.3µ ± 1%  -18.26% (p=0.002 n=6)
DecodeRemoteWrite/proto=v1/samples=2000-2   10.062m ± 31%   7.001m ± 2%  -30.42% (p=0.002 n=6)
DecodeRemoteWrite/proto=v2/samples=200-2     271.4µ ±  3%   231.5µ ± 1%  -14.71% (p=0.002 n=6)
DecodeRemoteWrite/proto=v2/samples=2000-2    2.470m ±  5%   2.033m ± 2%  -17.68% (p=0.002 n=6)
geomean                                      552.7µ         411.7µ       -25.51%

                                          │      go       │                rust                 │
                                          │      B/s      │     B/s       vs base               │
DecodeVarints/samples=2000-2                536.1Mi ±  1%   933.3Mi ± 2%  +74.09% (p=0.002 n=6)
DecodeRemoteWrite/proto=v1/samples=200-2    13.34Mi ±  2%   16.32Mi ± 2%  +22.35% (p=0.002 n=6)
DecodeRemoteWrite/proto=v1/samples=2000-2   10.70Mi ± 24%   15.38Mi ± 2%  +43.70% (p=0.002 n=6)
DecodeRemoteWrite/proto=v2/samples=200-2    29.19Mi ±  3%   34.22Mi ± 1%  +17.23% (p=0.002 n=6)
DecodeRemoteWrite/proto=v2/samples=2000-2   22.53Mi ±  5%   27.37Mi ± 2%  +21.48% (p=0.002 n=6)
geomean                                     34.70Mi         46.59Mi       +34.24%

                                          │       go       │                 rust                  │
                                          │      B/op      │     B/op      vs base                 │
DecodeVarints/samples=2000-2                  0.000 ± 0%       0.000 ± 0%        ~ (p=1.000 n=6) ¹
DecodeRemoteWrite/proto=v1/samples=200-2    613.6Ki ± 0%     687.8Ki ± 0%  +12.09% (p=0.002 n=6)
DecodeRemoteWrite/proto=v1/samples=2000-2   5.959Mi ± 0%     6.560Mi ± 0%  +10.08% (p=0.002 n=6)
DecodeRemoteWrite/proto=v2/samples=200-2    190.7Ki ± 0%     271.9Ki ± 0%  +42.59% (p=0.002 n=6)
DecodeRemoteWrite/proto=v2/samples=2000-2   1.568Mi ± 0%     2.053Mi ± 0%  +30.98% (p=0.002 n=6)
geomean                                                  ²                 +18.17%               ²
¹ all samples are equal
² summaries must be >0 to compute geomean

                                          │       go       │                 rust                 │
                                          │   allocs/op    │  allocs/op   vs base                 │
DecodeVarints/samples=2000-2                  0.000 ± 0%      0.000 ± 0%        ~ (p=1.000 n=6) ¹
DecodeRemoteWrite/proto=v1/samples=200-2    10.200k ± 0%     6.535k ± 0%  -35.93% (p=0.002 n=6)
DecodeRemoteWrite/proto=v1/samples=2000-2   101.83k ± 0%     65.22k ± 0%  -35.95% (p=0.002 n=6)
DecodeRemoteWrite/proto=v2/samples=200-2     2.189k ± 0%     1.905k ± 0%  -12.97% (p=0.002 n=6)
DecodeRemoteWrite/proto=v2/samples=2000-2    19.30k ± 0%     16.49k ± 0%  -14.55% (p=0.002 n=6)
geomean                                                  ²                -21.13%               ²
¹ all samples are equal
² summaries must be >0 to compute geomean
```

Look closely at the `B/op` and `allocs/op` tables. That is the kind of surprise you miss completely without allocation counters:

* Rust makes **35.95% fewer heap allocations** on Remote Write 1.0, `65,221 allocs/op` vs Go's `101,828 allocs/op`, and **14.55% fewer** on Remote Write 2.0, `16,490 allocs/op` vs `19,297 allocs/op`. In Go, `protoc-gen-go` generates pointer slices like `[]*TimeSeries`, `[]*Label`, and `[]*Sample`, allocating every nested struct separately on the heap. In Rust, `prost` stores `Vec<TimeSeries>`, `Vec<Label>`, and `Vec<Sample>` inline by value.
* Yet Rust requests **10.08% more heap bytes** on Remote Write 1.0, `6,878,664 B/op` or `6.56 MiB` vs Go's `6,248,868 B/op` or `5.96 MiB`, and **30.98% more heap bytes** on Remote Write 2.0, `2,153,196 B/op` or `2.05 MiB` vs Go's `1,643,970 B/op` or `1.57 MiB`!

Why would inline structs allocate *more* bytes? Because `benchfmt-rs` also supports `-cpuprofile` and `-memprofile` via its optional `pprof` feature, we do not have to guess:

```bash
cargo bench --bench suite_decode -- \
    -bench 'proto=v2/samples=2000' -benchtime 50x -count 1 \
    -memprofile /tmp/rw2_mem.pb.gz -memprofilerate 1

go tool pprof -top -alloc_space /tmp/rw2_mem.pb.gz
```

```text
Duration: 5.78s, Total samples = 102.67MB
      flat  flat%   sum%        cum   cum%
   90.72MB 88.36% 88.36%    90.72MB 88.36%  <alloc::raw_vec::RawVecInner>::grow_amortized (inline)
   11.96MB 11.64%   100%   102.67MB   100%  rust_go_decode::decode_remote_write_v2
         0     0%   100%    23.65MB 23.04%  <alloc::raw_vec::RawVec<u32>>::grow_one
         0     0%   100%    21.85MB 21.28%  <alloc::raw_vec::RawVec<rust_go_decode::proto::v2::TimeSeries>>::grow_one
         0     0%   100%     8.70MB  8.47%  <alloc::raw_vec::RawVec<rust_go_decode::proto::v2::Sample>>::grow_one
```

`50` iterations times `2,153,196 B/op` equals `102.67 MiB`, and `88.36%` of it comes from `RawVecInner::grow_amortized`:

1. `prost` decodes packed `repeated uint32 labels_refs` by pushing one `u32` at a time without pre-sizing from the wire byte length. Each 22- to 24-element series `Vec<u32>` grows through capacities `4 -> 8 -> 16 -> 32`, and together with 2-element exemplar `labels_refs` accounts for `23.04%` of all allocated bytes.
2. Growing `Vec<v2::TimeSeries>` from `0` to `2,048` reallocates inline 112-byte structs at every power of two, accounting for `21.28%` of allocated bytes, whereas Go only doubles an 8-byte `[]*TimeSeries` pointer slice.
3. Rust's `RawVec::MIN_NON_ZERO_CAP` allocates capacity `4`, or `96` bytes, the moment you push a single 24-byte `Sample` into an empty `Vec<Sample>`. Across `1,900` series, that accounts for another `8.47%` of allocated bytes.

We can also pivot the exact same two files by `-col /proto` to compare Remote Write 1.0 vs 2.0 across both languages in one command:

```bash
benchstat -filter ".name:DecodeRemoteWrite" -col /proto results/go.txt results/rust_suite.txt
```

```text
                                           │      v1       │                 v2                 │
                                           │    sec/op     │   sec/op     vs base               │
DecodeRemoteWrite/samples=200/lang=go-2       895.9µ ±  2%   271.4µ ± 3%  -69.71% (p=0.002 n=6)
DecodeRemoteWrite/samples=2000/lang=go-2     10.062m ± 31%   2.470m ± 5%  -75.45% (p=0.002 n=6)
DecodeRemoteWrite/samples=200/lang=rust-2     732.3µ ±  1%   231.5µ ± 1%  -68.39% (p=0.002 n=6)
DecodeRemoteWrite/samples=2000/lang=rust-2    7.001m ±  2%   2.033m ± 2%  -70.96% (p=0.002 n=6)
geomean                                       2.607m         749.5µ       -71.26%
```

Remote Write 2.0's symbol table cuts decode latency by ~70% and allocation counts by 71% to 81% regardless of whether your receiver is written in Go or Rust. Protocol design beats language micro-optimizations every time.

## Checking our microbenchmarks with a standalone binary and `/usr/bin/time -v`

Microbenchmarks run inside an artificial loop with a hot instruction cache, a warm allocator, and a custom `#[global_allocator]` wrapper in `suite_decode`. Are those `ns/op` and `B/op` numbers real when we ship an unmodified release binary?

To verify, I wrote two standalone CLI binaries, `src/bin/verify_decode.rs` using Rust's default `System` allocator with no benchmark library, and `cmd/verify_decode/main.go` in Go. Each binary runs `N` iterations, accumulates a checksum so nothing is dead-code-eliminated, and optionally retains `K` decoded messages in a `Vec` or slice via `--retain K` to simulate an in-memory ingestion queue. Then I ran both under GNU `/usr/bin/time -v`, setting `GOMAXPROCS=2` on Go to match `-cpu 2`:

```bash
cargo build --release --bin verify_decode
/usr/bin/time -v ./target/release/verify_decode --case rw1_2000 --iters 500 --retain 0
/usr/bin/time -v ./target/release/verify_decode --case rw1_2000 --iters 500 --retain 500
```

Here is what `/usr/bin/time -v` reported across all runs:

| Run | Microbench `sec/op` | Binary wall `ns/op` | Total CPU, user + sys | CPU % | Max RSS |
| --- | --- | --- | --- | --- | --- |
| Rust `varints`, `500,000` iters | `4.90 µs`, `4,902 ns/op` | `5.74 µs`, `5,740 ns/op` | `2.89s`, `5.78 µs/op` | `99%` | `2.44 MiB`, `2,500 KiB` |
| Go `varints`, `500,000` iters, `GOMAXPROCS=2` | `8.54 µs`, `8,536 ns/op` | `8.64 µs`, `8,638 ns/op` | `4.34s`, `8.68 µs/op` | `100%` | `6.11 MiB`, `6,260 KiB` |
| Rust `rw1_2000`, `500` iters, `retain=0` | `7.00 ms`, `7,001,455 ns/op` | `7.16 ms`, `7,157,616 ns/op` | `3.57s`, `7.14 ms/op` | `99%` | `8.73 MiB`, `8,944 KiB` |
| Go `rw1_2000`, `500` iters, `GOMAXPROCS=2` | `10.06 ms`, `10,061,889 ns/op` | `9.37 ms`, `9,374,060 ns/op` | `6.89s`, `13.78 ms/op` | `146%` | `33.49 MiB`, `34,292 KiB` |
| Rust `rw2_2000`, `1,000` iters, `retain=0` | `2.03 ms`, `2,033,355 ns/op` | `2.22 ms`, `2,218,969 ns/op` | `2.22s`, `2.22 ms/op` | `99%` | `4.21 MiB`, `4,308 KiB` |
| Go `rw2_2000`, `1,000` iters, `GOMAXPROCS=2` | `2.47 ms`, `2,470,127 ns/op` | `2.97 ms`, `2,969,833 ns/op` | `4.28s`, `4.28 ms/op` | `144%` | `15.98 MiB`, `16,364 KiB` |
| Rust `rw1_2000`, `500` iters, **`retain=500`** | `7.00 ms` | `17.21 ms`, `17,206,855 ns/op` | `9.75s`, `4.64s` user + `5.11s` sys | `99%` | `2,371.6 MiB`, `2,428,520 KiB` |
| Rust `rw2_2000`, `1,000` iters, **`retain=1000`** | `2.03 ms` | `2.75 ms`, `2,750,380 ns/op` | `3.18s`, `2.12s` user + `1.06s` sys | `99%` | `1,292.4 MiB`, `1,323,452 KiB` |

Cross-checking microbenchmarks against `/usr/bin/time -v` exposed three things that every performance engineer should keep in mind:

1. **`CountingAlloc` did not distort latency.** On `rw1_2000`, `benchfmt::Suite` measured `7.00 ms/op` while intercepting `65,221` heap allocations per iteration, roughly 9.3 million `malloc` calls per second. The standalone `System`-allocator binary ran at `7.16 ms/op`, a `2.2%` difference. Updating a thread-local `Cell<(u64, u64)>` costs a couple of instructions next to `glibc` `malloc`.
2. **`B/op` measures cumulative allocator churn, not peak RSS.** Over `500` iterations of `rw1_2000`, Rust allocated `500 * 6.56 MiB = 3.20 GiB` of heap memory, yet peak RSS with `retain=0` stayed flat at **`8.73 MiB`** with `2,124` minor page faults. Because each `WriteRequest` drops at the end of the loop body, `glibc` recycles the exact same thread-cache chunks on the next iteration without asking Linux for fresh pages. When we pass `--retain 500` to keep all `500` decoded requests alive at once, RSS jumps to `2,371.6 MiB`, or **`4.73 MiB` per retained message**. How do we get from `6.56 MiB` in `B/op` to `4.73 MiB` of live RSS? Each decode frees `1.37 MiB`, or `1,433,186` bytes, for the temporary Snappy decompression `Vec<u8>` plus `~1.44 MiB` of intermediate `Vec` doubling buffers during `realloc`, leaving `~3.75 MiB` of live Rust capacity, and `glibc` `ptmalloc2` adds `~0.98 MiB` of chunk headers and alignment padding across the `~61,000` live allocations per message. Faulting in `2.3 GiB` of brand-new pages also added `5.11s` of kernel `sys` time across `607,074` minor page faults, more than doubling per-op latency from `7.16 ms` to `17.21 ms`.
3. **Wall-clock `ns/op` hides Go's background GC CPU and RSS overhead.** In the `benchstat` table, Rust looked `30.42%` faster than Go on `rw1_2000` at `7.00 ms` vs `10.06 ms`, and `17.68%` faster on `rw2_2000` at `2.03 ms` vs `2.47 ms`. Under `/usr/bin/time -v` at `GOMAXPROCS=2`, Rust used `99%` of a single core, `7.14 ms` of CPU time per op, and `8.73 MiB` RSS. Go hit **`146%` CPU**, burning `6.89s` of total CPU over `500` ops, or **`13.78 ms` of CPU core-time per op** with `5,182` voluntary context switches, and **`33.49 MiB` RSS**. When `GOMAXPROCS` was left unrestricted on all 24 cores, Go climbed to `199%` CPU, `18.34 ms` of CPU core-time per op, and `37.44 MiB` RSS. Go's concurrent garbage collector was sweeping `101,828` heap objects per request on a second OS thread while the benchmark loop kept running. In real CPU core-seconds burned per decoded request, Rust used **1.9x less CPU** and **3.8x less RAM** than Go at `GOMAXPROCS=2`, and **2.6x less CPU** and **4.3x less RAM** when `GOMAXPROCS` was unrestricted.

## When to reach for what

Having both `benchfmt` tools in Rust lets me match the workflow to the job:

* Keep **standalone Criterion** when you want self-contained HTML violin plots or async executor adapters without installing Go's `benchstat`.
* Run **`benchfmt criterion target/criterion`** on existing Criterion suites when you want `benchstat` A/B tables across git commits or cross-language comparisons without editing benchmark source files.
* Reach for **`benchfmt::Suite` and `CountingAlloc`**, adding `--features pprof` when profiling, when writing new Rust microbenchmarks. You get near-instant `std`-only compiles, steady-state epochs for `benchstat`, deterministic `B/op` and `allocs/op` regression tracking, and scoped `-cpuprofile` and `-memprofile` files ready for `go tool pprof`.
* Whenever a microbenchmark informs an architectural decision, spend two extra minutes running the loop in a standalone release binary under `/usr/bin/time -v`. `benchstat` tells you what your code asked the CPU and allocator to do per operation. `/usr/bin/time -v` tells you what the runtime, allocator caches, garbage collector, and Linux kernel actually charged your process.

Give [`benchfmt-rs`](https://github.com/bwplotka/benchfmt-rs) a spin and let me know on GitHub what breaks or what is missing!
