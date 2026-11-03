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

Recently, I've been working on a few Rust projects across Google and [open source](https://github.com/prometheus/expfmt-rs), mostly because I think Rust has real potential in this AI era:
* It has extreme [compile-time verification](https://doc.rust-lang.org/book/ch10-02-traits.html), including strict [ownership and memory safety checks](https://doc.rust-lang.org/book/ch04-00-understanding-ownership.html), which is ideal when AI generates code.
* It takes ages and can be frustrating to program in by hand (sorry!), but AI writes a lot of code nowadays. Code mostly has to be readable for reviews, and Rust is good enough at that.
* It has a great columnar storage library ecosystem, such as [`arrow-rs`](https://github.com/apache/arrow-rs).
* It has no garbage collector, gives more flexibility over memory allocations, and is generally faster!

I came to Rust after years of writing performance-sensitive Go in [Prometheus](https://prometheus.io/), [Thanos](https://thanos.io/), and more. I even wrote the ["Efficient Go" book](/book) teaching those practices. For me, much of Rust's performance story is really good, until... you want to run **A/B microbenchmarks**. Perhaps I was spoiled by the Go benchmarking ecosystem, where [`benchstat`](https://pkg.go.dev/golang.org/x/perf/cmd/benchstat) sits at the center of everyone's workflow (see why in my [previous post](/2024/go-microbenchmarks-benchstat/)).

How can Rust claim to be more "performance-oriented" when its official benchmarking tooling misses:
* a standard format for case comparison projections,
* standard heap allocation measurements,
* standard `pprof` support,
* Mann-Whitney U p-value reliability scores?

So I asked myself: what if we could get `benchstat`-compatible output for Rust microbenchmarks? Wouldn't that make A/B testing easier and unlock fun Go vs Rust comparisons?

Here we are. I built [`benchfmt-rs`](https://github.com/bwplotka/benchfmt-rs), a zero-dependency Rust benchmark runner with a thread-local heap allocation counter, `pprof` profiler integration, and the same CLI flags as `go test -bench`. For those who don't trust a new benchmarking runtime (you shouldn't from the start!), it also ships a [`Criterion`](https://crates.io/crates/criterion) and `libtest` converter that emits Go's [`benchfmt`](https://go.googlesource.com/proposal/+/master/design/14313-benchmark-format.md) format directly.

In this blog post, let's implement the same pieces of code in Go and Rust, benchmark them across different Rust frameworks, and compare the results. We might learn something new along the way (I did when building this!). Enjoy! All benchmark code and raw outputs live in [`bwplotka/benchmarks/benchmarks/rust-go-decode`](https://github.com/bwplotka/benchmarks/tree/main/benchmarks/rust-go-decode).

## Benchmarking two workloads, varints and decoding Prometheus Remote Write 2 proto

Let's pick two workloads to implement and benchmark in both Go and Rust. I am particularly curious about protobuf decoding performance, which, funny enough, is one of the main costs of running distributed systems these days. Let's decode our [Prometheus Remote Write 2.0 protocol](https://prometheus.io/docs/specs/prw/remote_write_spec_2_0/). Because protobuf code generators have different maturity and trade-offs across languages, let's also measure something simpler alongside it, a standalone `varint` decoder:

1. **`DecodeVarints`.** A 36-line unsigned LEB128 varint stream decoder. Varints are the integer encoding underneath Protocol Buffers. Our fixture `varints_2000.bin` is `4,798` bytes and packs `2,000` `uint64` values mixing 1-byte symbol indices, 2-byte bucket offsets, 4-byte deltas, and 6-byte millisecond Unix timestamps. The function writes into a preallocated `2,000`-element slice with zero heap allocations.
2. **`DecodeRemoteWrite2`.** A full HTTP request body decoder for Remote Write 2.0 `io.prometheus.write.v2.Request` messages. Each operation takes a Snappy-block-compressed payload and unmarshals the full protobuf tree for batches of `200` and `2,000` series, where `2,000` matches Prometheus's default `max_samples_per_send`. Each `2,000`-series batch mixes `500` counters, `400` gauges, `100` classic 8-bucket histograms totaling `1,000` series, `100` native exponential histograms, `1,000` trace exemplars, and metric metadata. Remote Write 2.0 interns all strings into a single `repeated string symbols` table at the top of the message and stores packed varint `labels_refs` indices per series, shrinking the `2,000`-series batch to `244.9 KiB` uncompressed and `57.0 KiB` Snappy-compressed.

To keep the comparison honest, a deterministic Go generator writes the binary fixtures once into `testdata/` alongside a `manifest.json` file. That manifest records uncompressed byte sizes, series counts, sample counts, and an XOR checksum of all IEEE-754 sample bits (`56757976630294132` for the `2,000`-series batch). Unit tests in both Go and Rust assert that every decoder produces the exact manifest counts and checksums before we time anything.

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

For `DecodeRemoteWrite2`, we tune Go the way Prometheus runs in production rather than benchmarking slow reflection-based unmarshaling. We pair [`github.com/golang/snappy`](https://github.com/golang/snappy), which uses x86-64 assembly on `linux/amd64`, with [`vtprotobuf`](https://github.com/planetscale/vtprotobuf) and its generated `UnmarshalVT` decoder:

```go
func DecodeRemoteWrite2(compressed []byte) (*writev2.Request, error) {
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

In `benchmark_test.go`, we follow Go's `/key=value` sub-benchmark naming convention, such as `samples=2000/lang=go`, so `benchstat` can project across `/lang` or `/samples` later. We also call `b.SetBytes` with the input byte length and `b.ReportAllocs` before `for b.Loop()`. Let's run `6` epochs of `2s` each at `-cpu 2` on a 24-core Intel Xeon 2.20GHz Linux workstation using Go 1.26.8 and Rust 1.99.1:

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
BenchmarkDecodeVarints/samples=2000/lang=go-2          279861      8514 ns/op   563.52 MB/s        0 B/op        0 allocs/op
BenchmarkDecodeRemoteWrite2/samples=200/lang=go-2        8467    264321 ns/op    31.43 MB/s   195296 B/op     2189 allocs/op
BenchmarkDecodeRemoteWrite2/samples=2000/lang=go-2        976   2448633 ns/op    23.84 MB/s  1643970 B/op    19297 allocs/op
```

Across all 6 epochs, `DecodeVarints` runs at a median of `8.54 µs` (`8,536 ns/op`) with `0 B/op` and `0 allocs/op`. `DecodeRemoteWrite2` takes `271.4 µs` at `200` series and `2.47 ms` (`2,470,127 ns/op`) at `2,000` series, allocating `1.57 MiB` (`1,643,970 B/op`) across `19,297 allocs/op`.

## Implementing in Rust with Criterion and spotting the gaps

Now let's port both decoders to Rust. `decode_varints` in `src/varints.rs` mirrors the Go loop line for line. For Remote Write 2.0, we pair the standard [`snap`](https://crates.io/crates/snap) crate with [`prost`](https://crates.io/crates/prost) compile-time generated `Message` structs:

```rust
pub fn decode_remote_write2(compressed: &[u8]) -> Result<proto::v2::Request, String> {
    let raw = snap::raw::Decoder::new()
        .decompress_vec(compressed)
        .map_err(|e| e.to_string())?;
    proto::v2::Request::decode(raw.as_slice()).map_err(|e| e.to_string())
}
```

In the Rust ecosystem, [`Criterion`](https://crates.io/crates/criterion) is the default choice for stable-Rust microbenchmarking. Writing `benches/criterion_decode.rs` with the same `/key=value` benchmark IDs and `Throughput::Bytes` is straightforward:

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

DecodeRemoteWrite2/samples=200/lang=rust
                        time:   [237.09 µs 238.48 µs 239.95 µs]
                        thrpt:  [33.017 MiB/s 33.220 MiB/s 33.414 MiB/s]

DecodeRemoteWrite2/samples=2000/lang=rust
                        time:   [2.0712 ms 2.0831 ms 2.0968 ms]
                        thrpt:  [26.546 MiB/s 26.720 MiB/s 26.874 MiB/s]
```

Criterion is a thoughtful library, and its linear regression slope estimator works well for standalone Rust work. Once you want Go-style `benchstat` workflows or cross-language comparisons, five concrete differences get in the way:

1. **Compile weight.** Pulling in `criterion`, even with `default-features = false`, brings in `clap`, `regex-automata`, `ciborium`, `oorandom`, `itertools`, `tinytemplate`, and `anes`. That adds 42 transitive crates and ~19s to a cold `cargo bench` build.
2. **Binary `MiB/s` vs decimal `MB/s`.** Criterion formats `Throughput::Bytes` as binary `MiB/s` (`1,048,576` B/s), whereas Go's `testing.B.SetBytes` prints decimal `MB/s` (`1,000,000` B/s). Comparing `857.38 MiB/s` against Go's `563.52 MB/s` by eye silently introduces a `4.86%` unit mismatch unless you switch to `Throughput::BytesDecimal` or recompute from raw nanoseconds.
3. **Linear-ramp sampling vs steady-state epochs.** Go's `testing.B` calibrates an iteration count `N` until one run hits `-benchtime 2s`, then executes `-count 6` independent runs at that fixed `N` for `benchstat`'s Mann-Whitney U test. Criterion defaults to `Linear` sampling instead: after a 3-second warmup, it collects 100 samples of `[1d, 2d, ..., 100d]` iterations into `sample.json` and fits a slope through the origin.
4. **No heap allocation tracking.** Criterion reports wall-clock time and throughput only. On `DecodeVarints` at `0 allocs/op`, that is fine. On `DecodeRemoteWrite2`, we have no idea whether `prost` made 500 heap allocations or 500,000, or whether a refactor doubled heap churn.
5. **Pairwise baseline folders vs multi-dimensional tables.** Criterion compares `target/criterion/<id>/base` against `new`. You cannot take a single run file and pivot `-col /samples` or `-col /lang` across Go and Rust.

## Converting Criterion output with the `benchfmt` CLI

If a Rust codebase already has Criterion benchmarks, rewriting them just to get a `benchstat` table is annoying. That is why `benchfmt-rs` ships a zero-dependency `benchfmt` CLI binary. It walks `target/criterion`, reads `benchmark.json` and `sample.json` directly, converts `Throughput::Bytes` into Go's decimal `MB/s`, and groups Criterion's 100 samples into `6` contiguous epochs via `--epochs 6` by default:

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
                                  │     go      │                rust                │
                                  │   sec/op    │   sec/op     vs base               │
DecodeVarints/samples=2000-2        8.536µ ± 1%   5.364µ ± 5%  -37.16% (p=0.002 n=6)
DecodeRemoteWrite2/samples=200-2    271.4µ ± 3%   235.1µ ± 4%  -13.37% (p=0.002 n=6)
DecodeRemoteWrite2/samples=2000-2   2.470m ± 5%   2.082m ± 1%  -15.72% (p=0.002 n=6)
geomean                             178.9µ        138.0µ       -22.87%

                                  │      go      │                rust                 │
                                  │     B/s      │     B/s       vs base               │
DecodeVarints/samples=2000-2        536.1Mi ± 1%   853.2Mi ± 5%  +59.15% (p=0.002 n=6)
DecodeRemoteWrite2/samples=200-2    29.19Mi ± 3%   33.70Mi ± 4%  +15.44% (p=0.002 n=6)
DecodeRemoteWrite2/samples=2000-2   22.53Mi ± 5%   26.74Mi ± 1%  +18.67% (p=0.002 n=6)
geomean                             70.65Mi        91.60Mi       +29.67%

                                  │       go       │
                                  │      B/op      │
DecodeVarints/samples=2000-2          0.000 ± 0%
DecodeRemoteWrite2/samples=200-2    190.7Ki ± 0%
DecodeRemoteWrite2/samples=2000-2   1.568Mi ± 0%
geomean                                          ¹
¹ summaries must be >0 to compute geomean

                                  │      go       │
                                  │   allocs/op   │
DecodeVarints/samples=2000-2         0.000 ± 0%
DecodeRemoteWrite2/samples=200-2    2.189k ± 0%
DecodeRemoteWrite2/samples=2000-2   19.30k ± 0%
geomean                                         ¹
¹ summaries must be >0 to compute geomean
```

Once both files speak `benchfmt`, `benchstat` normalizes Go's decimal `MB/s` lines into binary `MiB/s` under `B/s` automatically. Rust is `37.16%` faster on `DecodeVarints` (`5.36 µs` vs `8.54 µs`) and `13.37%` to `15.72%` faster on `DecodeRemoteWrite2`.

Look at the bottom half of that output, though. The `B/op` and `allocs/op` tables only show a `go` column because Criterion never recorded allocations. And if you inspect `results/rust_criterion.txt`, bucket 1 of `DecodeVarints` summed `24,888` iterations while bucket 6 summed `286,212` iterations because of Criterion's linear ramp, leaving `± 5%` variance on a deterministic pure-CPU loop.

## Native `benchfmt` runs with `benchfmt::Suite` and `CountingAlloc`

When writing new Rust benchmarks, we can skip Criterion altogether and use `benchfmt::Suite` in `benches/suite_decode.rs` with `harness = false` in `Cargo.toml`. Registering `CountingAlloc` as `#[global_allocator]` makes every `alloc`, `alloc_zeroed`, and `realloc` update a `const`-initialized `thread_local!` `Cell<(u64, u64)>` with zero atomic contention across threads and zero external crate dependencies:

```rust
use std::hint::black_box;

use benchfmt::{CountingAlloc, Suite};
use rust_go_decode::{decode_remote_write2, decode_varints};

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
        // ... DecodeRemoteWrite2 200 and 2000 cases ...
        .run();
}
```

`Suite::from_env` accepts the same flags as `go test`:

```bash
cargo bench --bench suite_decode -- \
    -bench '^BenchmarkDecode' -benchtime 2s -count 6 -cpu 2 -benchmem \
| tee results/rust_suite.txt
```

First, let's check whether `benchfmt::Suite`, even with `CountingAlloc` active on every allocation, agrees with Criterion on timing:

```bash
benchstat criterion=results/rust_criterion.txt suite=results/rust_suite.txt
```

```text
                                            │  criterion  │               suite               │
                                            │   sec/op    │   sec/op     vs base              │
DecodeRemoteWrite2/samples=2000/lang=rust-2   2.082m ± 1%   2.033m ± 2%  -2.33% (p=0.015 n=6)
DecodeRemoteWrite2/samples=200/lang=rust-2    235.1µ ± 4%   231.5µ ± 1%  -1.55% (p=0.004 n=6)
DecodeVarints/samples=2000/lang=rust-2        5.364µ ± 5%   4.902µ ± 2%  -8.60% (p=0.002 n=6)
geomean                                       138.0µ        132.1µ       -4.21%
```

On `DecodeRemoteWrite2`, Criterion and `benchfmt::Suite` agree within `1.6%` to `2.3%` (`2.033 ms` vs `2.082 ms` at `2,000` series), while `Suite`'s steady-state `2s` epochs tighten worst-case variance from `± 4-5%` down to `± 1-2%`. On the `4.9 µs` `DecodeVarints` loop, `while b.keep_running()` executes `490,000` back-to-back iterations in one tight loop instead of calling a closure across 100 short ramp batches, clocking `4.90 µs` vs `5.36 µs`.

Now let's run the full Go vs Rust comparison with `results/rust_suite.txt`:

```bash
benchstat -col /lang results/go.txt results/rust_suite.txt
```

```text
goos: linux
goarch: amd64
pkg: github.com/bwplotka/benchmarks/benchmarks/rust-go-decode
cpu: Intel(R) Xeon(R) CPU @ 2.20GHz
                                  │     go      │                rust                │
                                  │   sec/op    │   sec/op     vs base               │
DecodeVarints/samples=2000-2        8.536µ ± 1%   4.902µ ± 2%  -42.56% (p=0.002 n=6)
DecodeRemoteWrite2/samples=200-2    271.4µ ± 3%   231.5µ ± 1%  -14.71% (p=0.002 n=6)
DecodeRemoteWrite2/samples=2000-2   2.470m ± 5%   2.033m ± 2%  -17.68% (p=0.002 n=6)
geomean                             178.9µ        132.1µ       -26.12%

                                  │      go      │                rust                 │
                                  │     B/s      │     B/s       vs base               │
DecodeVarints/samples=2000-2        536.1Mi ± 1%   933.3Mi ± 2%  +74.09% (p=0.002 n=6)
DecodeRemoteWrite2/samples=200-2    29.19Mi ± 3%   34.22Mi ± 1%  +17.23% (p=0.002 n=6)
DecodeRemoteWrite2/samples=2000-2   22.53Mi ± 5%   27.37Mi ± 2%  +21.48% (p=0.002 n=6)
geomean                             70.65Mi        95.62Mi       +35.35%

                                  │       go       │                 rust                  │
                                  │      B/op      │     B/op      vs base                 │
DecodeVarints/samples=2000-2          0.000 ± 0%       0.000 ± 0%        ~ (p=1.000 n=6) ¹
DecodeRemoteWrite2/samples=200-2    190.7Ki ± 0%     271.9Ki ± 0%  +42.59% (p=0.002 n=6)
DecodeRemoteWrite2/samples=2000-2   1.568Mi ± 0%     2.053Mi ± 0%  +30.98% (p=0.002 n=6)
geomean                                          ²                 +23.15%               ²
¹ all samples are equal
² summaries must be >0 to compute geomean

                                  │      go       │                 rust                 │
                                  │   allocs/op   │  allocs/op   vs base                 │
DecodeVarints/samples=2000-2         0.000 ± 0%      0.000 ± 0%        ~ (p=1.000 n=6) ¹
DecodeRemoteWrite2/samples=200-2    2.189k ± 0%     1.905k ± 0%  -12.97% (p=0.002 n=6)
DecodeRemoteWrite2/samples=2000-2   19.30k ± 0%     16.49k ± 0%  -14.55% (p=0.002 n=6)
geomean                                         ²                 -9.40%               ²
¹ all samples are equal
² summaries must be >0 to compute geomean
```

Look closely at the `B/op` and `allocs/op` tables. That is the kind of surprise you miss completely without allocation counters:

* Rust makes **14.55% fewer heap allocations** at `2,000` series (`16,490` vs Go's `19,297 allocs/op`). In Go, `protoc-gen-go` generates pointer slices such as `[]*TimeSeries` and `[]*Sample`, allocating every nested struct separately on the heap. In Rust, `prost` stores `Vec<TimeSeries>` and `Vec<Sample>` inline by value.
* Yet Rust requests **30.98% more heap bytes** at `2,000` series (`2.05 MiB` vs Go's `1.57 MiB`) and **42.59% more** at `200` series (`271.9 KiB` vs `190.7 KiB`)!

## Profiling both benchmarks in Go and Rust with `go tool pprof`

`benchstat` tells us *what* changed (`-42.56%` `sec/op` on `DecodeVarints`, `-17.68%` `sec/op` yet `+30.98%` `B/op` on `DecodeRemoteWrite2`), while [`pprof`](https://github.com/google/pprof) tells us *why*. Because `benchfmt::Suite` supports the same `-cpuprofile`, `-memprofile`, and `-memprofilerate` flags as `go test` via `--features pprof`, we can profile both benchmarks in both languages and inspect every `.pb.gz` file with `go tool pprof`.

### CPU profiling `DecodeVarints`

`DecodeVarints` does zero heap allocations in both languages, yet Rust finishes in `4.90 µs` while Go takes `8.54 µs` for the same loop. Let's capture a 3-second single-threaded CPU profile from each runner and inspect source-line samples with `go tool pprof -list`:

```bash
go test -run '^$' -bench '^BenchmarkDecodeVarints$' -benchtime 3s -count 1 -cpu 1 \
    -cpuprofile /tmp/go_varints_cpu.pb.gz

cargo bench --bench suite_decode -- \
    -bench '^BenchmarkDecodeVarints/' -benchtime 3s -count 1 -cpu 1 \
    -cpuprofile /tmp/rust_varints_cpu.pb.gz

go tool pprof -list DecodeVarints /tmp/go_varints_cpu.pb.gz
go tool pprof -list decode_varints /tmp/rust_varints_cpu.pb.gz
```

Here is the annotated Go loop next to Rust's `decode_varints`:

```text
ROUTINE ======================== DecodeVarints in varints.go
     3.66s      3.71s (flat, cum) 99.73% of Total
     540ms      540ms     31:	for i < len(src) {
     230ms      230ms     32:		if n >= len(dst) { ... }
      10ms       10ms     36:		b := src[i]
     150ms      160ms     37:		i++
         .          .     38:		if b < 0x80 {
         .          .     39:			dst[n] = uint64(b)
      40ms       40ms     40:			n++
         .          .     41:			continue
         .          .     42:		}
     200ms      200ms     43:		x := uint64(b & 0x7f)
     250ms      250ms     45:		for {
     200ms      200ms     46:			if i >= len(src) { ... }
      30ms       30ms     49:			b := src[i]
     300ms      310ms     50:			i++
     1.22s      1.24s     51:			x |= uint64(b&0x7f) << shift
     220ms      230ms     52:			if b < 0x80 { break }
      50ms       50ms     55:			shift += 7
      10ms       10ms     56:			if shift >= 64 { ... }
         .          .     59:		}
     210ms      210ms     61:		n++
         .          .     62:	}

ROUTINE ======================== rust_go_decode::varints::decode_varints in src/varints.rs
     3.30s      3.30s (flat, cum) 99.70% of Total
         .          .     50:            b = src[i];
         .          .     51:            i += 1;
         .          .     52:            x |= u64::from(b & 0x7f) << shift;
     3.30s      3.30s     53:            if b < 0x80 { break; }
```

Both languages spend over `99.7%` of CPU inside the varint loop, yet Go burns **`1.24s` (`33.4%`)** on `x |= uint64(b&0x7f) << shift` alone and another **`770ms` (`20.8%`)** on the loop guards. Checking `go tool objdump` shows two codegen differences behind the `42.56%` gap:

1. **64-bit variable shift masking.** Go defines `x << shift` to evaluate to `0` when `shift >= 64`, whereas x86 `SHLQ` masks the shift count modulo 64. Because `if shift >= 64` runs *after* the shift, the Go compiler inserts `CMPQ $64`, `SBBQ`, and `ANDQ` on every continuation byte. Rust's release-mode `<<` maps to a bare `SHLQ`.
2. **Signed `int` vs unsigned `usize` indices.** Go's `i` and `n` are signed `int`, so `i < len(src)` and `n >= len(dst)` do not prove `i >= 0` or `n >= 0` to the bounds-check eliminator, leaving extra unsigned `CMPQ`/`JBE` slice bounds checks on `src[i]` and `dst[n]`. Rust's `i` and `n` are unsigned `usize`, so LLVM removes every inner bounds check and inlines `decode_varints` directly into `while b.keep_running()`.

### CPU and heap profiling `DecodeRemoteWrite2`

Next, let's collect both `-cpuprofile` and `-memprofile` on the `2,000`-series Remote Write 2.0 benchmark in Go and Rust:

```bash
# CPU profiles (3s at -cpu 1)
go test -run '^$' -bench '^BenchmarkDecodeRemoteWrite2/samples=2000/' -benchtime 3s -count 1 -cpu 1 \
    -cpuprofile /tmp/go_rw2_cpu.pb.gz
cargo bench --bench suite_decode -- \
    -bench 'DecodeRemoteWrite2/samples=2000' -benchtime 3s -count 1 -cpu 1 \
    -cpuprofile /tmp/rust_rw2_cpu.pb.gz

# Exact heap profiles (50 iterations with every allocation sampled)
go test -run '^$' -bench '^BenchmarkDecodeRemoteWrite2/samples=2000/' -benchtime 50x -count 1 -cpu 1 \
    -memprofile /tmp/go_rw2_mem.pb.gz -memprofilerate 1
cargo bench --bench suite_decode -- \
    -bench 'DecodeRemoteWrite2/samples=2000' -benchtime 50x -count 1 -cpu 1 \
    -memprofile /tmp/rust_rw2_mem.pb.gz -memprofilerate 1
```

Inspecting the two CPU profiles first with `go tool pprof -top -cum /tmp/go_rw2_cpu.pb.gz` and `go tool pprof -top /tmp/rust_rw2_cpu.pb.gz` shows completely different bottlenecks:

```text
# Go CPU profile (Duration: 3.75s, Total samples = 3.68s)
      flat  flat%   sum%        cum   cum%
     0.11s  2.99%  2.99%      3.12s 84.78%  io/prometheus/write/v2.(*Request).UnmarshalVT
     0.41s 11.14% 14.13%      2.25s 61.14%  io/prometheus/write/v2.(*TimeSeries).UnmarshalVT
     0.18s  4.89% 19.02%      2.07s 56.25%  runtime.mallocgc
     0.03s  0.82% 19.84%      1.17s 31.79%  runtime.newobject
     0.09s  2.45% 26.09%      0.55s 14.95%  io/prometheus/write/v2.(*Histogram).UnmarshalVT
         0     0% 26.36%      0.53s 14.40%  runtime.gcAssistAlloc

# Rust CPU profile (Duration: 3.75s, Total samples = 2.27s)
      flat  flat%   sum%        cum   cum%
     0.31s 13.78% 13.78%      0.52s 22.67%  prost::encoding::varint::decode_varint::<&mut &[u8]>
     0.21s  9.33% 23.11%      0.71s 31.11%  prost::encoding::merge_loop::<Vec<u32>, ...>
     0.20s  8.89% 32.00%      0.20s  8.89%  <snap::decompress::Decompress>::read_copy (inline)
     0.14s  6.22% 38.22%      1.62s 71.11%  <v2::TimeSeries as prost::Message>::merge_field
     0.05s  2.22% 64.00%      0.42s 18.67%  <alloc::raw_vec::RawVecInner>::grow_amortized (inline)
```

In Go, `UnmarshalVT` accounts for `84.78%` of cumulative time, **yet `runtime.mallocgc` alone consumes `56.25%` (`2.07s`) of on-CPU time**, including `14.40%` inside `runtime.gcAssistAlloc`! Over half of Go's `2.47 ms/op` is spent allocating and GC-scanning `19,297` heap objects rather than parsing wire bytes. In Rust, there is zero GC work: `71.11%` cum sits in `prost` field decoding (`22.67%` in `decode_varint` and `31.11%` in `merge_loop` on packed `u32` `labels_refs`), `8.89%` flat in `snap` decompression, and **`18.67%` cum inside `RawVecInner::grow_amortized`**.

Why is `RawVecInner::grow_amortized` eating nearly `19%` of Rust's CPU time *and* pushing Rust's `B/op` `30.98%` higher than Go? Comparing both heap profiles with `go tool pprof -top -alloc_space` answers that immediately:

```text
# Go heap profile (50 iterations, Total samples = 80.51MB)
      flat  flat%   sum%        cum   cum%
   28.18MB 35.00% 35.00%    67.87MB 84.29%  io/prometheus/write/v2.(*Request).UnmarshalVT
   28.05MB 34.84% 69.84%    39.69MB 49.29%  io/prometheus/write/v2.(*TimeSeries).UnmarshalVT
   12.40MB 15.40% 85.24%    12.40MB 15.40%  github.com/golang/snappy.Decode
   11.25MB 13.97% 99.21%    11.25MB 13.97%  io/prometheus/write/v2.(*Histogram).UnmarshalVT

# Rust heap profile (50 iterations, Total samples = 102.67MB)
      flat  flat%   sum%        cum   cum%
   90.72MB 88.36% 88.36%    90.72MB 88.36%  <alloc::raw_vec::RawVecInner>::grow_amortized (inline)
   11.96MB 11.64%   100%   102.67MB   100%  rust_go_decode::decode_remote_write2
         0     0%   100%    23.65MB 23.04%  <alloc::raw_vec::RawVec<u32>>::grow_one
         0     0%   100%    21.85MB 21.28%  <alloc::raw_vec::RawVec<rust_go_decode::proto::v2::TimeSeries>>::grow_one
         0     0%   100%     8.70MB  8.47%  <alloc::raw_vec::RawVec<rust_go_decode::proto::v2::Sample>>::grow_one
```

Go allocates `80.51 MB` (`50 * 1.57 MiB`) mostly as exact-sized `*TimeSeries`, `*Sample`, `*Histogram`, and symbol `string` objects in `UnmarshalVT` plus `12.40 MB` for Snappy decompression, wasting very little spare slice capacity. Rust allocates `102.67 MB` (`50 * 2.05 MiB`), and **`88.36%` (`90.72 MB`) comes from `RawVec` doubling reallocations**:

1. `prost` decodes packed `repeated uint32 labels_refs` by pushing one `u32` at a time without pre-sizing from the wire byte length. Each 22- to 24-element series `Vec<u32>` grows through capacities `4 -> 8 -> 16 -> 32`. Together with 2-element exemplar `labels_refs`, this accounts for `23.04%` of all allocated bytes.
2. Growing `Vec<v2::TimeSeries>` from `0` to `2,048` reallocates inline 112-byte structs at every power of two (`21.28%` of allocated bytes), whereas Go only doubles an 8-byte `[]*TimeSeries` pointer slice.
3. Rust's `RawVec::MIN_NON_ZERO_CAP` allocates capacity `4` (`96` bytes) the moment you push a single 24-byte `Sample` into an empty `Vec<Sample>`. Across `1,900` series, that accounts for another `8.47%` of allocated bytes.

## Checking our microbenchmarks with a standalone binary and `/usr/bin/time -v`

Microbenchmarks run inside an artificial loop with a hot instruction cache, a warm allocator, and a custom `#[global_allocator]` wrapper in `suite_decode`. Do those `ns/op` and `B/op` numbers hold up when we ship an unmodified release binary?

To verify, I wrote two standalone CLI binaries: `src/bin/verify_decode.rs` using Rust's default `System` allocator with no benchmark library, and `cmd/verify_decode/main.go` in Go. Each binary runs `N` iterations, accumulates a checksum so nothing gets dead-code-eliminated, and optionally keeps `K` decoded messages alive via `--retain K` to simulate an in-memory ingestion queue. Then I ran both under GNU `/usr/bin/time -v`, setting `GOMAXPROCS=2` on Go to match `-cpu 2`:

```bash
cargo build --release --bin verify_decode
/usr/bin/time -v ./target/release/verify_decode --case rw2_2000 --iters 1000 --retain 0
/usr/bin/time -v ./target/release/verify_decode --case rw2_2000 --iters 1000 --retain 1000
```

Here is what `/usr/bin/time -v` reported across all runs:

| Run | Microbench `sec/op` | Binary wall `/op` | Total CPU (`user + sys`) | CPU % | Max RSS |
| --- | --- | --- | --- | --- | --- |
| Rust `varints` (`500,000` iters) | `4.90 µs` | `5.74 µs` | `2.89s` (`5.78 µs/op`) | `99%` | `2.44 MiB` |
| Go `varints` (`500,000` iters, `GOMAXPROCS=2`) | `8.54 µs` | `8.64 µs` | `4.34s` (`8.68 µs/op`) | `100%` | `6.11 MiB` |
| Rust `rw2_2000` (`1,000` iters, `retain=0`) | `2.03 ms` | `2.22 ms` | `2.22s` (`2.22 ms/op`) | `99%` | `4.21 MiB` |
| Go `rw2_2000` (`1,000` iters, `GOMAXPROCS=2`) | `2.47 ms` | `2.97 ms` | `4.28s` (`4.28 ms/op`) | `144%` | `15.98 MiB` |
| Rust `rw2_2000` (`1,000` iters, **`retain=1000`**) | `2.03 ms` | `2.75 ms` | `3.18s` (`2.12s` user + `1.06s` sys) | `99%` | `1,292.4 MiB` |

Cross-checking microbenchmarks against `/usr/bin/time -v` exposed three things worth keeping in mind:

1. **`CountingAlloc` did not distort latency.** On `rw2_2000`, `benchfmt::Suite` measured `2.03 ms/op` while counting `16,490` heap allocations per iteration (over 8 million `malloc` calls per second). The standalone `System`-allocator binary ran at `2.22 ms/op` across `1,000` cold-start iterations. Updating a thread-local `Cell<(u64, u64)>` costs only a couple of instructions next to `glibc` `malloc`.
2. **`B/op` measures cumulative allocator churn, not peak RSS.** Over `1,000` iterations of `rw2_2000`, Rust allocated `1,000 * 2.05 MiB = 2.00 GiB` of heap memory, yet peak RSS with `retain=0` stayed flat at **`4.21 MiB`**. Each `Request` drops at the end of the loop body, so `glibc` recycles the same freed thread-cache chunks on the next iteration without asking Linux for fresh pages. When `--retain 1000` keeps all `1,000` decoded batches alive at once, RSS jumps to `1,292.4 MiB`, or **`1.29 MiB` per retained message**. That drop from `2.05 MiB` in `B/op` to `1.29 MiB` in live RSS comes from freeing the `244.9 KiB` temporary Snappy buffer and `~0.77 MiB` of intermediate `Vec` doubling buffers during `realloc`, plus `~0.25 MiB` of `glibc` chunk headers and alignment padding across the live allocations. Faulting in `1.29 GiB` of new pages also added `1.06s` of kernel `sys` time across `330,378` minor page faults, raising per-op wall latency from `2.22 ms` to `2.75 ms`.
3. **Wall-clock `ns/op` hides Go's background GC CPU and RAM overhead.** In the `benchstat` table, Rust looked `17.68%` faster than Go on `rw2_2000` (`2.03 ms` vs `2.47 ms`). Under `/usr/bin/time -v` at `GOMAXPROCS=2`, Rust used `99%` of a single core (`2.22 ms` of CPU time per op) and `4.21 MiB` RSS. Go hit **`144%` CPU**, burning `4.28s` of total CPU over `1,000` ops (**`4.28 ms` of CPU core-time per op**) with `8,444` voluntary context switches and **`15.98 MiB` RSS**. When `GOMAXPROCS` was left unrestricted on all 24 cores, Go climbed to **`220%` CPU** (`7.13 ms` of CPU core-time per op) and `18.53 MiB` RSS as concurrent GC swept `19,297` heap objects per request on background threads. In real CPU core-seconds and memory per decoded request, Rust used **1.9x less CPU and 3.8x less RAM** than Go at `GOMAXPROCS=2`, and **3.2x less CPU and 4.4x less RAM** when `GOMAXPROCS` was unrestricted.

## When to reach for what

Having both `benchfmt` tools in Rust lets me match the workflow to the job:

* Keep **standalone Criterion** when you want self-contained HTML violin plots or async executor adapters without installing Go's `benchstat`.
* Run **`benchfmt criterion target/criterion`** on existing Criterion suites when you want `benchstat` A/B tables across git commits or cross-language comparisons without editing benchmark source files.
* Reach for **`benchfmt::Suite` and `CountingAlloc`** (adding `--features pprof` when profiling) when writing new Rust microbenchmarks. You get near-instant `std`-only compiles, steady-state epochs for `benchstat`, deterministic `B/op` and `allocs/op` regression tracking, and scoped `-cpuprofile` and `-memprofile` files ready for `go tool pprof`.
* Whenever a microbenchmark informs an architectural decision, spend two extra minutes running the loop in a standalone release binary under `/usr/bin/time -v`. `benchstat` tells you what your code asked the CPU and allocator to do per operation. `/usr/bin/time -v` tells you what the runtime, allocator caches, garbage collector, and Linux kernel actually charged your process.

Give [`benchfmt-rs`](https://github.com/bwplotka/benchfmt-rs) a spin and let me know on GitHub what breaks or what is missing!
