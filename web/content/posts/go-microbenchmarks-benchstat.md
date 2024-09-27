---
title: "benchstat: Flexible analysis of Go microbenchmark results you might not know about!"
date: "2024-09-25"
categories:
- go
- efficiency
featuredImage: "/og-images/gophermetric.png"
---

Many have been written and spoken about the [Go built-in (micro-)benchmarking framework](https://pkg.go.dev/testing#hdr-Benchmarks), available with those special `func BenchmarkXYZ(b *testing.B)` testing functions and executed with `go test -bench BenchmarkXYZ` Go command. I wrote about micro-benchmarking in Go extensively in [my "Efficient Go" book (Chapter 8)](/book), but there are also free resources e.g. [generally up-to-date 10y old good Dave's Cheney blog post](https://dave.cheney.net/2013/06/30/how-to-write-benchmarks-in-go).

However, not many know about the amazingly useful [`benchstat` tool](https://pkg.go.dev/golang.org/x/perf/cmd/benchstat). It allows readable comparisons (diffs) of results across comparable benchmark runs. I literally cannot imagine analysing micro benchmarks results without `benchstat` and I wished it was a bit more visible and explained in the Go community.

While I was enjoying `benchstat` I did miss an important feature -- you could only compare the benchmark results stored in different files. This was getting a bit annoying when you would like to compare benchmark results across different [`b.Run(...)`](https://pkg.go.dev/testing#B.Run) cases. Such a comparison flow was becoming more handy (at least for my mental model), the more I was doing benchmarks, and I even initially planned to contribute/write another tool for that!

Gladly I didn't, because in January 2023, `benchstat` was [rewritten](https://cs.opensource.google/go/x/perf/+/02c55175bb825ade4507ee5d459ea6a1ab6e0af5). Austin Clements, with reviewers, added a new flexible filtering and control on what you want to compare with what. The rewrite also improved other things e.g. warnings insufficient `-count` (number of benchmark runs) to detect and reject outliers and overall detection of non-matching results.

The new `benchstat` changes are not yet covered in my book, plus there is a specific naming convention you need to use in your [`b.Run(...)`](https://pkg.go.dev/testing#B.Run) cases to leverage the powerful projection/filtering `benchstat` [syntax](https://pkg.go.dev/golang.org/x/perf/benchproc/syntax). The syntax also can be a bit intuitive at the start. All of this gives an amazing opportunity to share a brief blog post on how to enhance your benchmarks and use `benchstat` effectively and reliably.

> NOTE: I am here to learn too, so feel free to give feedback on what I could explain or do better!

So... get that terminal warmed up by installing `benchstat` with `go install golang.org/x/perf/cmd/benchstat@latest` command and let's go!

## Old-school flow: Comparing efficiency across versions

Let's start by explaining the most popular iterative benchmarking flow, where we run the same benchmark on multiple versions of the code.

Generally, from a high level point of view, it works by:

1. Creating a `func BenchmarkXYZ(b *testing.B)` function, with or without [`b.Run(...)`](https://pkg.go.dev/testing#B.Run) cases that benchmarks a portion of your code.
2. Running that benchmark, ideally at least 6 times (`-count 6`) so outlier detection can do its work (tell you when your results are widely different, thus less reliable) and save the results to e.g. `old.txt` file.
3. You can then git commit whatever you had (just to not get lost!), change the code you are benchmarking (e.g. in an attempt to optimize it based on previously gathered profiles) and execute the same benchmark to produce new numbers e.g. in `new.txt` file.
4. Run `benchstat old.txt new.txt` or `benchstat base=old.txt new=new.txt` (for nice headers) to compare `old.txt` with `new.txt`. You will see the absolute latency, allocations (and any custom metrics you reported) numbers, but also the relative percentages of improvements/regressions for those, and the probability of noise.

After those steps you likely know if new changes improved CPU latency or memory consumption or made it worse, or if you have to repeat (or fix!) the benchmark due to noise.

### Example

To showcase this, I wrote a quick [example benchmark](https://github.com/bwplotka/my/blob/f35da419e4ce429acd414bafcbc5a50ff4ad3c8d/web/content/code/go-microbenchmarks-benchstat/across_versions/benchmark_test.go#L47) ported from [the real microbenchmark](https://github.com/bwplotka/benchmarks/tree/main/benchmarks/metrics-streaming#metric-streaming) I did when preparing for the PromCon talk about Remote Write 2.0.

The main benchmark goal is to compare Remote Write 1.0 protocol to Remote Write 2.0 protocol for different sample sizes, ideally across different compressions and two different Go protobuf encoders (marshallers). If we did this across different version it may look like this:

```go
package across_versions

// ...

/*
	export bench=new && go test \
		 -run '^$' -bench '^BenchmarkEncode' \
		 -benchtime 5s -count 6 -cpu 2 -benchmem -timeout 999m \
	 | tee ${bench}.txt
*/
func BenchmarkEncode(b *testing.B) {
	for _, sampleCase := range sampleCases {
		b.Run(fmt.Sprintf("sample=%v", sampleCase.samples), func(b *testing.B) {
			batch := utils.GeneratePrometheusMetricsBatch(sampleCase.config)

			// Commenting out what we used in old.txt
			//msg := utils.ToV1(batch, true, true)
			msg := utils.ToV2(utils.ConvertClassicToCustom(batch))

			compr := newCompressor("zstd")
			marsh := newMarshaller("protobuf")

			b.ReportAllocs()
			b.ResetTimer()
			for i := 0; i < b.N; i++ {
				out, err := marsh.marshal(msg)
				testutil.Ok(b, err)

				out = compr.compress(out)
				b.ReportMetric(float64(len(out)), "bytes/message")
			}
		})
	}
}
```

In this flow one could comment things out or in, or change directly and repeat the benchmark while changing the output file in the handy `export bench=<file-name> ...` CLI command.

After old and new results are generated (in this example [old](https://github.com/bwplotka/my/blob/f35da419e4ce429acd414bafcbc5a50ff4ad3c8d/web/content/code/go-microbenchmarks-benchstat/across_versions/old.txt) means `Remote Write 1.0` proto message and [new](https://github.com/bwplotka/my/blob/f35da419e4ce429acd414bafcbc5a50ff4ad3c8d/web/content/code/go-microbenchmarks-benchstat/across_versions/new.txt) means 2.0), we can use `benchstat` to compare it:

```bash
$ benchstat base=old.txt new=new.txt
goos: darwin
goarch: arm64
pkg: go-microbenchmarks-benchstat/across_versions
                      │     base     │                new                 │
                      │    sec/op    │   sec/op     vs base               │
Encode/sample=200-2      264.7µ ± 3%   107.0µ ± 4%  -59.58% (p=0.002 n=6)
Encode/sample=2000-2    2672.9µ ± 3%   900.3µ ± 3%  -66.32% (p=0.002 n=6)
Encode/sample=10000-2   13.335m ± 4%   3.299m ± 6%  -75.26% (p=0.002 n=6)
geomean                  2.113m        682.4µ       -67.70%

                      │     base      │                 new                  │
                      │ bytes/message │ bytes/message  vs base               │
Encode/sample=200-2      5.964Ki ± 1%    5.534Ki ± 0%   -7.21% (p=0.002 n=6)
Encode/sample=2000-2     45.88Ki ± 0%    33.45Ki ± 0%  -27.08% (p=0.002 n=6)
Encode/sample=10000-2    227.4Ki ± 0%    122.0Ki ± 3%  -46.33% (p=0.002 n=6)
geomean                  39.62Ki         28.27Ki       -28.66%

                      │     base      │                 new                 │
                      │     B/op      │     B/op      vs base               │
Encode/sample=200-2     336.76Ki ± 0%   64.02Ki ± 0%  -80.99% (p=0.002 n=6)
Encode/sample=2000-2    1807.7Ki ± 0%   370.8Ki ± 0%  -79.49% (p=0.002 n=6)
Encode/sample=10000-2    9.053Mi ± 0%   1.322Mi ± 0%  -85.40% (p=0.002 n=6)
geomean                  1.739Mi        317.9Ki       -82.14%

                      │    base     │                 new                 │
                      │  allocs/op  │ allocs/op   vs base                 │
Encode/sample=200-2      2.000 ± 0%   2.000 ± 0%        ~ (p=1.000 n=6) ¹
Encode/sample=2000-2    10.000 ± 0%   2.000 ± 0%  -80.00% (p=0.002 n=6)
Encode/sample=10000-2   16.000 ± 0%   2.000 ± 0%  -87.50% (p=0.002 n=6)
geomean                  6.840        2.000       -70.76%
¹ all samples are equal
```

The above tells us that Remote Write 2.0 is both smaller on the wire and uses less CPU and Memory to encode (and compress) with `zstd` compression.

### Benefits

There are reason why this method is a default way people microbenchmark.

* It's simple, especially for an interactive quick benchmarking session, where you run a quick benchmark and you don't intend to reuse the benchmarking code for later, or by others.
* Does not require complex benchmarking code and gets you started and learn about efficiency of your code fast. It is true, that the more complex benchmark is, the more mistakes we can make to measure wrong things (e.g. measuring benchmark code vs the actual code or measuring code that yields wrong results.

### Downsides

There are cases where this flow is not the most optimal. Let's enumerate some limitations:

* It's easy to get lost in changes. Especially if you forget about git versioning properly, it's get easy to track what exactly you benchmark, especially if you notice you ideas are not helping and you need to revert to some local minimum state.
* It's easy to accidentally change benchmark itself in a different version. This makes it highly unreliably to compare results across those, especially if you don't notice benchmark changes. If you notice them, it's painful to retro-fit new benchmark code with older code you want to benchmark to have proper `old.txt` results.
* The above issues around getting lost, prohibits or make it even harder to share the true benchmark state with other people. This is a big blocker for bigger projects, where reviews need to ensure reliability of the author's benchmark and claimed results. 

  No one assumes wrong intention, but it's extremely easy to make a little mistake in benchmarking, so replicating benchmarks by multiple people is highly recommended before making decisions. 

* Micro-benchmarks are NOT about the absolute values, but the relative difference of resource use and latency across benchmark runs. This is because we want to run them locally, for fast development feedback loop and low risk, instead of the actual production environment with all the production dependencies. However, even relative numbers can be unreliable if you run microbenchmark across different hardware, but also if you run on same hardware, but in a different condition (e.g. different browser tabs opened during benchmark!). 

    As a result the longer you "work" on your next version, the more unreliable your benchmark process is in practice. This can be mitigated by going back (e.g. in git) to the old version, running a benchmark, then going to the new code, doing it again and then the "time" gap between benchmark runs are minimal. The other interesting mitigation I saw e.g. in Dave Cheney flow is to pre-build binaries with benchmark test and keep them well describe, so you can always execute benchmark one after another. Both mitigations are a bit painful in practice.

* The above issues are even bigger if you want to benchmark your code across different cases like we did in our example. 

## Newly enabled flow: Comparing efficiency across cases

The idea is simple--for reproducibility, reliability and clarity we try to capture the new and old "code" as a different cases. Anyone can the run this benchmark once and produce one result file. Finally, anyone can use then a new `benchstat` projection and filtering features to compare results from that one run, across different dimensions, on the fly.

One important detail to remember when making things work with the `benchstat` projection feature, is that all cases should follow a [proposed format](https://go.googlesource.com/proposal/+/master/design/14313-benchmark-format.md) of `<case name>=<case value>`. For example, to represent old and new protobuf versions, we could do `proto=prometheus.WriteRequest` (which is the official unique package name for 1.0) and `proto=io.prometheus.write.v2.Request` for 2.0.

### Example

Let's adapt the previous example into a new [`across_cases` example benchmark](https://github.com/bwplotka/my/blob/f35da419e4ce429acd414bafcbc5a50ff4ad3c8d/web/content/code/go-microbenchmarks-benchstat/across_cases/benchmark_test.go).

Notice the obvious increase of the complexity for the benchmarking test and the strict syntax for cases:

```go
package across_cases

// ...

/*
	export bench=allcases && go test \
		 -run '^$' -bench '^BenchmarkEncode' \
		 -benchtime 5s -count 6 -cpu 2 -benchmem -timeout 999m \
	 | tee ${bench}.txt
*/
func BenchmarkEncode(b *testing.B) {
  for _, sampleCase := range sampleCases {
    b.Run(fmt.Sprintf("sample=%v", sampleCase.samples), func(b *testing.B) {
      for _, compr := range compressionCases {
        b.Run(fmt.Sprintf("compression=%v", compr.name()), func(b *testing.B) {
          for _, protoCase := range protoCases {
            b.Run(fmt.Sprintf("proto=%v", protoCase.name), func(b *testing.B) {
              for _, marshaller := range marshallers {
                b.Run(fmt.Sprintf("encoder=%v", marshaller.name()), func(b *testing.B) {
                  msg := protoCase.msgFromConfigFn(sampleCase.config)

                  b.ReportAllocs()
                  b.ResetTimer()
                  for i := 0; i < b.N; i++ {
                    out, err := marshaller.marshal(msg)
                    testutil.Ok(b, err)

                    out = compr.compress(out)
                    b.ReportMetric(float64(len(out)), "bytes/message")
                  }
                })
              }
            })
          }
        })
      }
    })
  }
}

var (
  sampleCases = []struct {
    samples int
    config  utils.GenerateConfig
  }{
    {samples: 200, config: generateConfig200samples},
    {samples: 2000, config: generateConfig2000samples},
    {samples: 10000, config: generateConfig10000samples},
  }
  compressionCases = []*compressor{
    newCompressor(""),
    newCompressor(remote.SnappyBlockCompression),
    newCompressor("zstd"),
  }
  protoCases = []struct {
    name            string
    msgFromConfigFn func(config utils.GenerateConfig) vtprotobufEnhancedMessage
  }{
    {
      name: "prometheus.WriteRequest",
      msgFromConfigFn: func(config utils.GenerateConfig) vtprotobufEnhancedMessage {
        return utils.ToV1(utils.GeneratePrometheusMetricsBatch(config), true, true)
      },
    },
    {
      name: "io.prometheus.write.v2.Request",
      msgFromConfigFn: func(config utils.GenerateConfig) vtprotobufEnhancedMessage {
        return utils.ToV2(utils.ConvertClassicToCustom(utils.GeneratePrometheusMetricsBatch(config)))
      },
    },
  }
  marshallers = []*marshaller{
    newMarshaller("protobuf"), newMarshaller("vtprotobuf"),
  }
)
```

In this flow, we could just execute the `export bench=allcases ...` CLI command once to produce [allcases]() file.

Now here is where the `benchstat` magic enables this use cases. Previously one would need to modify this single file and perhaps output it to two different files while removing some cases with `sed` or so for `benchstat` to work. Now, nothing like that is needed. We can use new [syntax](https://pkg.go.dev/golang.org/x/perf/benchproc/syntax) to decide the dimensions we want to compare across.

For example to produce similar output to the [across version flow](#old-school-flow--comparing-efficiency-across-versions) we can use `-filter "/compression:zstd /encoder:protobuf" -col /proto` parameters.

```bash
$ benchstat -filter "/compression:zstd /encoder:protobuf" -col /proto allcases.txt
goos: darwin
goarch: arm64
pkg: go-microbenchmarks-benchstat/across_cases
                                                        │ prometheus.WriteRequest │   io.prometheus.write.v2.Request   │
                                                        │         sec/op          │   sec/op     vs base               │
Encode/sample=200/compression=zstd/encoder=protobuf-2                 268.8µ ± 2%   103.3µ ± 7%  -61.57% (p=0.002 n=6)
Encode/sample=2000/compression=zstd/encoder=protobuf-2               2671.4µ ± 5%   877.4µ ± 4%  -67.16% (p=0.002 n=6)
Encode/sample=10000/compression=zstd/encoder=protobuf-2              12.834m ± 2%   3.059m ± 8%  -76.16% (p=0.002 n=6)
geomean                                                               2.097m        652.1µ       -68.90%

                                                        │ prometheus.WriteRequest │    io.prometheus.write.v2.Request    │
                                                        │      bytes/message      │ bytes/message  vs base               │
Encode/sample=200/compression=zstd/encoder=protobuf-2                5.949Ki ± 0%   5.548Ki ±  0%   -6.73% (p=0.002 n=6)
Encode/sample=2000/compression=zstd/encoder=protobuf-2               45.90Ki ± 0%   33.49Ki ±  0%  -27.03% (p=0.002 n=6)
Encode/sample=10000/compression=zstd/encoder=protobuf-2              227.8Ki ± 1%   121.4Ki ± 25%  -46.70% (p=0.002 n=6)
geomean                                                              39.62Ki        28.26Ki        -28.68%

                                                        │ prometheus.WriteRequest │   io.prometheus.write.v2.Request    │
                                                        │          B/op           │     B/op      vs base               │
Encode/sample=200/compression=zstd/encoder=protobuf-2               336.00Ki ± 0%   64.00Ki ± 0%  -80.95% (p=0.002 n=6)
Encode/sample=2000/compression=zstd/encoder=protobuf-2              1799.8Ki ± 1%   368.0Ki ± 0%  -79.55% (p=0.002 n=6)
Encode/sample=10000/compression=zstd/encoder=protobuf-2              9.015Mi ± 2%   1.312Mi ± 0%  -85.44% (p=0.002 n=6)
geomean                                                              1.732Mi        316.3Ki       -82.17%

                                                        │ prometheus.WriteRequest │   io.prometheus.write.v2.Request    │
                                                        │        allocs/op        │ allocs/op   vs base                 │
Encode/sample=200/compression=zstd/encoder=protobuf-2                  2.000 ± 0%   2.000 ± 0%        ~ (p=1.000 n=6) ¹
Encode/sample=2000/compression=zstd/encoder=protobuf-2                10.000 ± 0%   2.000 ± 0%  -80.00% (p=0.002 n=6)
Encode/sample=10000/compression=zstd/encoder=protobuf-2               16.000 ± 0%   2.000 ± 0%  -87.50% (p=0.002 n=6)
geomean                                                                6.840        2.000       -70.76%
¹ all samples are equal
```

We can also easily compare across compressions, giving us amazing flexibility when new question arises:

```bash
$ benchstat -filter /encoder:protobuf -col /compression allcases.txt
goos: darwin
goarch: arm64
pkg: go-microbenchmarks-benchstat/across_cases
                                                                            │             │               snappy                │                 zstd                 │
                                                                            │   sec/op    │    sec/op     vs base               │    sec/op     vs base                │
Encode/sample=200/proto=prometheus.WriteRequest/encoder=protobuf-2            129.3µ ± 2%   185.0µ ±  1%  +43.16% (p=0.002 n=6)    268.8µ ± 2%  +107.94% (p=0.002 n=6)
Encode/sample=200/proto=io.prometheus.write.v2.Request/encoder=protobuf-2     39.27µ ± 2%   61.31µ ±  2%  +56.15% (p=0.002 n=6)   103.30µ ± 7%  +163.08% (p=0.002 n=6)
Encode/sample=2000/proto=prometheus.WriteRequest/encoder=protobuf-2           1.172m ± 3%   1.541m ±  4%  +31.49% (p=0.002 n=6)    2.671m ± 5%  +128.02% (p=0.002 n=6)
Encode/sample=2000/proto=io.prometheus.write.v2.Request/encoder=protobuf-2    317.4µ ± 3%   478.9µ ±  6%  +50.86% (p=0.002 n=6)    877.4µ ± 4%  +176.39% (p=0.002 n=6)
Encode/sample=10000/proto=prometheus.WriteRequest/encoder=protobuf-2          6.071m ± 3%   8.405m ± 11%  +38.45% (p=0.002 n=6)   12.834m ± 2%  +111.41% (p=0.002 n=6)
Encode/sample=10000/proto=io.prometheus.write.v2.Request/encoder=protobuf-2   1.480m ± 2%   2.088m ±  3%  +41.06% (p=0.002 n=6)    3.059m ± 8%  +106.65% (p=0.002 n=6)
geomean                                                                       506.9µ        726.4µ        +43.30%                  1.169m       +130.67%

                                                                            │                │                snappy                │                 zstd                 │
                                                                            │ bytes/message  │ bytes/message  vs base               │ bytes/message  vs base               │
Encode/sample=200/proto=prometheus.WriteRequest/encoder=protobuf-2            161.389Ki ± 0%   15.606Ki ± 0%  -90.33% (p=0.002 n=6)   5.949Ki ±  0%  -96.31% (p=0.002 n=6)
Encode/sample=200/proto=io.prometheus.write.v2.Request/encoder=protobuf-2      31.241Ki ± 0%    8.273Ki ± 0%  -73.52% (p=0.002 n=6)   5.548Ki ±  0%  -82.24% (p=0.002 n=6)
Encode/sample=2000/proto=prometheus.WriteRequest/encoder=protobuf-2           1618.35Ki ± 0%   143.19Ki ± 0%  -91.15% (p=0.002 n=6)   45.90Ki ±  0%  -97.16% (p=0.002 n=6)
Encode/sample=2000/proto=io.prometheus.write.v2.Request/encoder=protobuf-2     176.57Ki ± 0%    59.89Ki ± 0%  -66.08% (p=0.002 n=6)   33.49Ki ±  0%  -81.03% (p=0.002 n=6)
Encode/sample=10000/proto=prometheus.WriteRequest/encoder=protobuf-2           8101.0Ki ± 0%    713.7Ki ± 0%  -91.19% (p=0.002 n=6)   227.8Ki ±  1%  -97.19% (p=0.002 n=6)
Encode/sample=10000/proto=io.prometheus.write.v2.Request/encoder=protobuf-2     666.8Ki ± 0%    258.6Ki ± 9%  -61.22% (p=0.002 n=6)   121.4Ki ± 25%  -81.79% (p=0.002 n=6)
geomean                                                                         445.2Ki         76.75Ki       -82.76%                 33.46Ki        -92.48%

                                                                            │              │                snappy                 │                 zstd                  │
                                                                            │     B/op     │     B/op       vs base                │     B/op       vs base                │
Encode/sample=200/proto=prometheus.WriteRequest/encoder=protobuf-2            168.0Ki ± 0%    360.0Ki ± 0%  +114.29% (p=0.002 n=6)    336.0Ki ± 0%  +100.00% (p=0.002 n=6)
Encode/sample=200/proto=io.prometheus.write.v2.Request/encoder=protobuf-2     32.00Ki ± 0%    72.00Ki ± 0%  +125.00% (p=0.002 n=6)    64.00Ki ± 0%  +100.00% (p=0.002 n=6)
Encode/sample=2000/proto=prometheus.WriteRequest/encoder=protobuf-2           1.586Mi ± 0%    3.438Mi ± 0%  +116.75% (p=0.002 n=6)    1.758Mi ± 1%   +10.82% (p=0.002 n=6)
Encode/sample=2000/proto=io.prometheus.write.v2.Request/encoder=protobuf-2    184.0Ki ± 0%    392.0Ki ± 0%  +113.04% (p=0.002 n=6)    368.0Ki ± 0%  +100.00% (p=0.002 n=6)
Encode/sample=10000/proto=prometheus.WriteRequest/encoder=protobuf-2          7.914Mi ± 0%   17.148Mi ± 0%  +116.68% (p=0.002 n=6)    9.015Mi ± 2%   +13.92% (p=0.002 n=6)
Encode/sample=10000/proto=io.prometheus.write.v2.Request/encoder=protobuf-2   672.0Ki ± 0%   1456.0Ki ± 0%  +116.67% (p=0.002 n=6)   1344.0Ki ± 0%  +100.00% (p=0.002 n=6)
geomean                                                                       453.9Ki         985.2Ki       +117.04%                  749.1Ki        +65.03%

                                                                            │            │               snappy               │                 zstd                 │
                                                                            │ allocs/op  │ allocs/op   vs base                │  allocs/op   vs base                 │
Encode/sample=200/proto=prometheus.WriteRequest/encoder=protobuf-2            1.000 ± 0%   2.000 ± 0%  +100.00% (p=0.002 n=6)    2.000 ± 0%   +100.00% (p=0.002 n=6)
Encode/sample=200/proto=io.prometheus.write.v2.Request/encoder=protobuf-2     1.000 ± 0%   2.000 ± 0%  +100.00% (p=0.002 n=6)    2.000 ± 0%   +100.00% (p=0.002 n=6)
Encode/sample=2000/proto=prometheus.WriteRequest/encoder=protobuf-2           1.000 ± 0%   2.000 ± 0%  +100.00% (p=0.002 n=6)   10.000 ± 0%   +900.00% (p=0.002 n=6)
Encode/sample=2000/proto=io.prometheus.write.v2.Request/encoder=protobuf-2    1.000 ± 0%   2.000 ± 0%  +100.00% (p=0.002 n=6)    2.000 ± 0%   +100.00% (p=0.002 n=6)
Encode/sample=10000/proto=prometheus.WriteRequest/encoder=protobuf-2          1.000 ± 0%   2.000 ± 0%  +100.00% (p=0.002 n=6)   16.000 ± 0%  +1500.00% (p=0.002 n=6)
Encode/sample=10000/proto=io.prometheus.write.v2.Request/encoder=protobuf-2   1.000 ± 0%   2.000 ± 0%  +100.00% (p=0.002 n=6)    2.000 ± 0%   +100.00% (p=0.002 n=6)
geomean                                                                       1.000        2.000       +100.00%                  3.699        +269.86% 
```




### Benefits

What's amazing in this flow?

In general, it makes our benchmarking results a bit more reproducible and reliable by mitigating all [the downsides of across versions flow](#downsides).

### Downsides

This flow has some negative consequences too.

* Rerunning benchmark with large amount of cases take more time.
* More complex benchmarking code.
* TBD more?

## Summary

TBD (:

Across version comparison is not worse or better, but it's a trade-off. 

In practice the best is potentially a hybrid mode.

If you don't know what to use, one learning is to at least follow [the proposed case syntax](https://go.googlesource.com/proposal/+/master/design/14313-benchmark-format.md), as a good practice (no harm in doing so).

Similar to OLAP

Extra benchstat not mentioned:

* CSV!


