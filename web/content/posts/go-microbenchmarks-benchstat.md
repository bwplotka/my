---
title: "Leveraging benchstat Projections in Go Benchmark Analysis!"
date: "2024-09-30"
categories:
- go
- efficiency
featuredImage: "/og-images/gophermetrics.png"
---

[Go's built-in micro-benchmarking framework](https://pkg.go.dev/testing#hdr-Benchmarks) is extremely useful and widely known. Sill, not many developers are aware of the additional, yet essential, [`benchstat` tool](https://pkg.go.dev/golang.org/x/perf/cmd/benchstat) allowing clear comparisons of Go A/B benchmark results across multiple runs. In 2023, `benchstat` received a complete overhaul making it even more powerful: projections, filtering and groupings were introduced allowing robust comparisons across any dimension, defined by your sub-benchmarks (aka "cases"), if you follow [a certain naming format](https://go.googlesource.com/proposal/+/master/design/14313-benchmark-format.md#:~:text=We%20propose%20that%20sub%2Dbenchmarks%20adopt%20the%20convention%20of%20choosing%20names%20that%20are%20key%3Dvalue%20pairs%3B%20that%20slash%2Dprefixed%20key%3Dvalue%20pairs%20in%20the%20benchmark%20name%20are%20treated%20by%20benchmark%20data%20processors%20as%20per%2Dbenchmark%20configuration%20values).

In this post, we will get you familiar with the `benchstat` tool and some Go benchmarking best practices. If you have read an older version of my ["Efficient Go" book](/book), this article will get you updated on the recent `benchstat` features.

So... get that terminal warmed up by installing `benchstat` with the `go install golang.org/x/perf/cmd/benchstat@latest` command and let's go!

## Old-school Flow: Comparing Efficiency Across Versions

Let's start by explaining the most popular iterative benchmarking flow, where we run the same benchmark on multiple versions of your code. Generally, the flow works by:

1. Creating the benchmark test code

    Creating a benchmark is as simple as creating a `func BenchmarkFoo(b *testing.B)` testing function in you `bar_test.go` file. Inside, you can optionally use multiple [`b.Run(...)`](https://pkg.go.dev/testing#B.Run) cases to benchmark different cases for similar functionality. I wrote about Go benchmarking extensively in [my "Efficient Go" book (Chapter 8)](/book), but there are also free resources e.g. [surprisingly up-to-date 10y old good Dave's Cheney blog post](https://dave.cheney.net/2013/06/30/how-to-write-benchmarks-in-go).

2. Running the benchmark for the version A of your code

    To run the `BenchmarkFoo` testing function quickly, for the default 1s time, you can use the `go test -bench BenchmarkFoo` command. This is good for testing things out, but typically we use more advanced options like (essential!) multiple runs (`-count`), CPU limits (`-cpu`), profiling (`-memprofile`) and more. In my book I recommend pairing it with `tee` so you stream the output to both `stdout` and file for future reference e.g. `v1.txt`:
  
    ```bash
    export bench=v1 && go test \
         -run '^$' -bench '^BenchmarkFoo' \
         -benchtime 5s -count 6 -cpu 2 -benchmem -timeout 999m \
     | tee ${bench}.txt 
    ```
  
    The resulting output contains absolute results (allocations, latency, custom metrics) from that benchmark run(s).

3. Optimize the code you are benchmarking

    You can then `git commit` whatever you had (just to not get lost!), and change the code you are benchmarking (e.g. in an attempt to optimize it based on previously gathered profiles). 

4. Running the benchmark for the version B of your code

    Now it's time to execute the same benchmark to see if your optimization is actually better or worse, while changing the output name to get lost e.g. in the `v2.txt` file.

5. Analyze the A/B benchmark results
   
    Once we have old and new (A and B) results, it's time to use the [`benchstat` tool](https://pkg.go.dev/golang.org/x/perf/cmd/benchstat)! Run `benchstat base=v1.txt new=v2.txt` to compare two versions. You will still see the absolute latency, allocations (and any custom metrics you reported) numbers, but what's more important--the relative percentages of improvements/regressions for those, and the probability of noise.

After those steps, you likely know if new changes improved CPU latency or memory consumption or made it worse, or if you have to repeat (or fix!) the benchmark due to noise. Let's go through a specific example!

### Example

To showcase this, I wrote a quick [example benchmark](https://github.com/bwplotka/my/blob/main/web/content/code/go-microbenchmarks-benchstat/across_versions/benchmark_test.go#L47) ported from [the real microbenchmark](https://github.com/bwplotka/benchmarks/tree/main/benchmarks/metrics-streaming#metric-streaming) I did when preparing for the [PromCon talk about Remote Write 2.0](https://www.youtube.com/watch?v=1sGmdQk22Ho).

The main benchmark goal is to compare the encoding efficiency of the Remote Write 1.0 protocol to the 2.0 version for different sample sizes, ideally across different compressions and two different Go protobuf encoders (marshallers). If we use "different versions" flow it may look like this:

```go
package across_versions

// ...

/*
	export bench=v2 && go test \
		 -run '^$' -bench '^BenchmarkEncode' \
		 -benchtime 5s -count 6 -cpu 2 -benchmem -timeout 999m \
	 | tee ${bench}.txt
*/
func BenchmarkEncode(b *testing.B) {
	for _, sampleCase := range sampleCases {
		b.Run(fmt.Sprintf("sample=%v", sampleCase.samples), func(b *testing.B) {
			batch := utils.GeneratePrometheusMetricsBatch(sampleCase.config)

			// Commenting out what we used in v1.txt
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

In this flow, one could comment things out or in, or change directly and repeat the benchmark while changing the output file in the handy `export bench=<file-name> ...` CLI command.

After old (v1) and new (v2) results are generated (in this example [v1](https://github.com/bwplotka/my/blob/main/web/content/code/go-microbenchmarks-benchstat/across_versions/v1.txt) means `Remote Write 1.0` proto message and [v2](https://github.com/bwplotka/my/blob/main/web/content/code/go-microbenchmarks-benchstat/across_versions/v2.txt) means 2.0), we can use `benchstat` to compare it:

```bash
$ benchstat base=v1.txt new=v2.txt
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

### Pros & Cons

While this traditional approach to Go micro benchmarking (modifying code and rerunning benchmarks) is simple for interactive, quick tests, it also has significant drawbacks:

* **Difficult to track changes**: It's easy to lost track of what exactly you benchmark, especially if you notice your current optimizations are not helping, and you need to revert to some previous state.
* **Accidental benchmark changes**: Unintentional modifications to the benchmark code itself can lead to unreliable comparisons and are hard to notice in this flow.
* **Limited collaboration**: Sharing and replicating benchmarks becomes challenging. This is a big blocker for bigger projects, where reviews need to ensure the reliability of the author's benchmark and claimed results.

  No one assumes the wrong intention, but it's extremely easy to make a little mistake in benchmarking, so replicating benchmarks by multiple people is highly recommended before making decisions. Recently more ways to do this on CI emerged too e.g. [github-action job for benchmarks](https://github.com/benchmark-action/github-action-benchmark) which helps a bit with that, but not with the small iterations you do on your own.

* **Environmental inconsistencies**: Micro-benchmarks are NOT about the absolute values, but the relative difference of resource use and latency across benchmark runs. This is because we want to run them locally, for a fast development feedback loop and low risk, instead of the actual production environment with all the production dependencies. However, even relative numbers can be unreliable e.g. if you benchmark different code version across different hardware or on the same hardware, but in a different conditions (e.g. different browser tabs opened during benchmarks!).

  As a result, the *longer* you work on your next version, the more unreliable your benchmark process is in practice. This can be mitigated by going back (e.g. in git) to the old version, running a benchmark, then going to the new code, doing it again to minimize the "time" gap between benchmark runs. The other interesting mitigation I saw e.g. in Dave Cheney's flow is to compile binaries with benchmark tests and keep them somewhere, well-described, so you can always execute benchmarks one after another. Both mitigations are a bit painful in practice.

* **Complex comparisons**: The above issues are even bigger if you want to benchmark your code across different cases like we did in our example.

These limitations are why I am excited to share an alternative flow, enabled with the new `benchstat` changes!

## Newly Enabled Flow: Comparing Efficiency Across Cases

While I was always enjoying `benchstat` I did miss an important feature--instead of comparing the benchmark results stored in different files, I wanted to compare the runs across [`b.Run(...)`](https://pkg.go.dev/testing#B.Run) sub-benchmarks/cases. Such a comparison flow was becoming more handy (at least for my mental model), the more I was doing benchmarks. I even initially planned to contribute/write another tool for that.

Gladly I didn't, because in January 2023, `benchstat` was [rewritten](https://cs.opensource.google/go/x/perf/+/02c55175bb825ade4507ee5d459ea6a1ab6e0af5). Austin Clements, with reviewers, added a new flexible filtering and control on what you want to compare with what. The rewrite also improved other things e.g. warnings insufficient `-count` (number of benchmark runs) to detect and reject outliers and overall detection of non-matching results. 

The idea behind this flow is simple--for reproducibility, reliability and clarity we try to capture the new and old "code" as different cases. Anyone can run this benchmark once and produce a single result file. Finally, anyone can use a new `benchstat` projection and filtering features to compare results from that one run, across different dimensions, on the fly.

One important detail to remember when making things work with the `benchstat` projection feature, is that all cases should follow a [proposed format](https://go.googlesource.com/proposal/+/master/design/14313-benchmark-format.md). Funny enough, this proposal was not changed since 2016, but only when writing this post I learned about this!

Specially, we need to ensure our [`b.Run(...)`](https://pkg.go.dev/testing#B.Run) sub benchmark case naming follow [`<case name>=<case value>`](https://go.googlesource.com/proposal/+/master/design/14313-benchmark-format.md#:~:text=We%20propose%20that%20sub%2Dbenchmarks%20adopt%20the%20convention%20of%20choosing%20names%20that%20are%20key%3Dvalue%20pairs%3B%20that%20slash%2Dprefixed%20key%3Dvalue%20pairs%20in%20the%20benchmark%20name%20are%20treated%20by%20benchmark%20data%20processors%20as%20per%2Dbenchmark%20configuration%20values.) pair format. For example, to represent v1 and v2 protobuf versions, we could do `proto=prometheus.WriteRequest` (which is the official unique package name for 1.0) and `proto=io.prometheus.write.v2.Request` for 2.0.

### Example

Let's adapt the previous example into a new [`across_cases` example benchmark](https://github.com/bwplotka/my/blob/main/web/content/code/go-microbenchmarks-benchstat/across_cases/benchmark_test.go).

Notice the obvious increase of the complexity for the benchmarking test and **the strict syntax** for sub-benchmark cases:

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

In this flow, we can just execute the `export bench=allcases ...` CLI command once to produce [allcases](https://github.com/bwplotka/my/blob/main/web/content/code/go-microbenchmarks-benchstat/across_cases/allcases.txt) file.

Now here is where the `benchstat` projection magic comes in. We can use new [syntax](https://pkg.go.dev/golang.org/x/perf/benchproc/syntax) to control what dimensions we want to compare across, what things we want to filter out or group by!

For example to produce similar output to the [across version flow](#old-school-flow--comparing-efficiency-across-versions) we can use `-filter "/compression:zstd /encoder:protobuf" -col /proto` parameters. We can also (optionally here) provide `-row ".name /sample /compression /encoder"` to group by the remaining dimension explicitly:

```bash
$ benchstat -row ".name /sample /compression /encoder" -filter "/compression:zstd /encoder:protobuf" -col /proto allcases.txt
```

```bash
goos: darwin
goarch: arm64
pkg: go-microbenchmarks-benchstat/across_cases
                           │ prometheus.WriteRequest │   io.prometheus.write.v2.Request   │
                           │         sec/op          │   sec/op     vs base               │
Encode 200 zstd protobuf                 268.8µ ± 2%   103.3µ ± 7%  -61.57% (p=0.002 n=6)
Encode 2000 zstd protobuf               2671.4µ ± 5%   877.4µ ± 4%  -67.16% (p=0.002 n=6)
Encode 10000 zstd protobuf              12.834m ± 2%   3.059m ± 8%  -76.16% (p=0.002 n=6)
geomean                                  2.097m        652.1µ       -68.90%

                           │ prometheus.WriteRequest │    io.prometheus.write.v2.Request    │
                           │      bytes/message      │ bytes/message  vs base               │
Encode 200 zstd protobuf                5.949Ki ± 0%   5.548Ki ±  0%   -6.73% (p=0.002 n=6)
Encode 2000 zstd protobuf               45.90Ki ± 0%   33.49Ki ±  0%  -27.03% (p=0.002 n=6)
Encode 10000 zstd protobuf              227.8Ki ± 1%   121.4Ki ± 25%  -46.70% (p=0.002 n=6)
geomean                                 39.62Ki        28.26Ki        -28.68%

                           │ prometheus.WriteRequest │   io.prometheus.write.v2.Request    │
                           │          B/op           │     B/op      vs base               │
Encode 200 zstd protobuf               336.00Ki ± 0%   64.00Ki ± 0%  -80.95% (p=0.002 n=6)
Encode 2000 zstd protobuf              1799.8Ki ± 1%   368.0Ki ± 0%  -79.55% (p=0.002 n=6)
Encode 10000 zstd protobuf              9.015Mi ± 2%   1.312Mi ± 0%  -85.44% (p=0.002 n=6)
geomean                                 1.732Mi        316.3Ki       -82.17%

                           │ prometheus.WriteRequest │   io.prometheus.write.v2.Request    │
                           │        allocs/op        │ allocs/op   vs base                 │
Encode 200 zstd protobuf                  2.000 ± 0%   2.000 ± 0%        ~ (p=1.000 n=6) ¹
Encode 2000 zstd protobuf                10.000 ± 0%   2.000 ± 0%  -80.00% (p=0.002 n=6)
Encode 10000 zstd protobuf               16.000 ± 0%   2.000 ± 0%  -87.50% (p=0.002 n=6)
geomean                                   6.840        2.000       -70.76%
¹ all samples are equal
```

We can also easily compare across compressions (switching to `-col` and updating `-row`), giving us amazing flexibility when new a question arises. We can also impact sorting order, no matter the original sorting in the raw `allcases` result file, by re-ordering the keys in the `-row` option:

```bash
$ benchstat -row ".name /proto /encoder /sample" -filter /encoder:protobuf -col /compression allcases.txt
```

{{< details title="👉🏽 Expand to see the output." >}}
```bash
goos: darwin
goarch: arm64
pkg: go-microbenchmarks-benchstat/across_cases
                                                     │             │               snappy                │                 zstd                 │
                                                     │   sec/op    │    sec/op     vs base               │    sec/op     vs base                │
Encode prometheus.WriteRequest protobuf 200            129.3µ ± 2%   185.0µ ±  1%  +43.16% (p=0.002 n=6)    268.8µ ± 2%  +107.94% (p=0.002 n=6)
Encode prometheus.WriteRequest protobuf 2000           1.172m ± 3%   1.541m ±  4%  +31.49% (p=0.002 n=6)    2.671m ± 5%  +128.02% (p=0.002 n=6)
Encode prometheus.WriteRequest protobuf 10000          6.071m ± 3%   8.405m ± 11%  +38.45% (p=0.002 n=6)   12.834m ± 2%  +111.41% (p=0.002 n=6)
Encode io.prometheus.write.v2.Request protobuf 200     39.27µ ± 2%   61.31µ ±  2%  +56.15% (p=0.002 n=6)   103.30µ ± 7%  +163.08% (p=0.002 n=6)
Encode io.prometheus.write.v2.Request protobuf 2000    317.4µ ± 3%   478.9µ ±  6%  +50.86% (p=0.002 n=6)    877.4µ ± 4%  +176.39% (p=0.002 n=6)
Encode io.prometheus.write.v2.Request protobuf 10000   1.480m ± 2%   2.088m ±  3%  +41.06% (p=0.002 n=6)    3.059m ± 8%  +106.65% (p=0.002 n=6)
geomean                                                506.9µ        726.4µ        +43.30%                  1.169m       +130.67%

                                                     │                │                snappy                │                 zstd                 │
                                                     │ bytes/message  │ bytes/message  vs base               │ bytes/message  vs base               │
Encode prometheus.WriteRequest protobuf 200            161.389Ki ± 0%   15.606Ki ± 0%  -90.33% (p=0.002 n=6)   5.949Ki ±  0%  -96.31% (p=0.002 n=6)
Encode prometheus.WriteRequest protobuf 2000           1618.35Ki ± 0%   143.19Ki ± 0%  -91.15% (p=0.002 n=6)   45.90Ki ±  0%  -97.16% (p=0.002 n=6)
Encode prometheus.WriteRequest protobuf 10000           8101.0Ki ± 0%    713.7Ki ± 0%  -91.19% (p=0.002 n=6)   227.8Ki ±  1%  -97.19% (p=0.002 n=6)
Encode io.prometheus.write.v2.Request protobuf 200      31.241Ki ± 0%    8.273Ki ± 0%  -73.52% (p=0.002 n=6)   5.548Ki ±  0%  -82.24% (p=0.002 n=6)
Encode io.prometheus.write.v2.Request protobuf 2000     176.57Ki ± 0%    59.89Ki ± 0%  -66.08% (p=0.002 n=6)   33.49Ki ±  0%  -81.03% (p=0.002 n=6)
Encode io.prometheus.write.v2.Request protobuf 10000     666.8Ki ± 0%    258.6Ki ± 9%  -61.22% (p=0.002 n=6)   121.4Ki ± 25%  -81.79% (p=0.002 n=6)
geomean                                                  445.2Ki         76.75Ki       -82.76%                 33.46Ki        -92.48%

                                                     │              │                snappy                 │                 zstd                  │
                                                     │     B/op     │     B/op       vs base                │     B/op       vs base                │
Encode prometheus.WriteRequest protobuf 200            168.0Ki ± 0%    360.0Ki ± 0%  +114.29% (p=0.002 n=6)    336.0Ki ± 0%  +100.00% (p=0.002 n=6)
Encode prometheus.WriteRequest protobuf 2000           1.586Mi ± 0%    3.438Mi ± 0%  +116.75% (p=0.002 n=6)    1.758Mi ± 1%   +10.82% (p=0.002 n=6)
Encode prometheus.WriteRequest protobuf 10000          7.914Mi ± 0%   17.148Mi ± 0%  +116.68% (p=0.002 n=6)    9.015Mi ± 2%   +13.92% (p=0.002 n=6)
Encode io.prometheus.write.v2.Request protobuf 200     32.00Ki ± 0%    72.00Ki ± 0%  +125.00% (p=0.002 n=6)    64.00Ki ± 0%  +100.00% (p=0.002 n=6)
Encode io.prometheus.write.v2.Request protobuf 2000    184.0Ki ± 0%    392.0Ki ± 0%  +113.04% (p=0.002 n=6)    368.0Ki ± 0%  +100.00% (p=0.002 n=6)
Encode io.prometheus.write.v2.Request protobuf 10000   672.0Ki ± 0%   1456.0Ki ± 0%  +116.67% (p=0.002 n=6)   1344.0Ki ± 0%  +100.00% (p=0.002 n=6)
geomean                                                453.9Ki         985.2Ki       +117.04%                  749.1Ki        +65.03%

                                                     │            │               snappy               │                 zstd                 │
                                                     │ allocs/op  │ allocs/op   vs base                │  allocs/op   vs base                 │
Encode prometheus.WriteRequest protobuf 200            1.000 ± 0%   2.000 ± 0%  +100.00% (p=0.002 n=6)    2.000 ± 0%   +100.00% (p=0.002 n=6)
Encode prometheus.WriteRequest protobuf 2000           1.000 ± 0%   2.000 ± 0%  +100.00% (p=0.002 n=6)   10.000 ± 0%   +900.00% (p=0.002 n=6)
Encode prometheus.WriteRequest protobuf 10000          1.000 ± 0%   2.000 ± 0%  +100.00% (p=0.002 n=6)   16.000 ± 0%  +1500.00% (p=0.002 n=6)
Encode io.prometheus.write.v2.Request protobuf 200     1.000 ± 0%   2.000 ± 0%  +100.00% (p=0.002 n=6)    2.000 ± 0%   +100.00% (p=0.002 n=6)
Encode io.prometheus.write.v2.Request protobuf 2000    1.000 ± 0%   2.000 ± 0%  +100.00% (p=0.002 n=6)    2.000 ± 0%   +100.00% (p=0.002 n=6)
Encode io.prometheus.write.v2.Request protobuf 10000   1.000 ± 0%   2.000 ± 0%  +100.00% (p=0.002 n=6)    2.000 ± 0%   +100.00% (p=0.002 n=6)
geomean                                                1.000        2.000       +100.00%                  3.699        +269.86%
```
{{< /details >}}

### Pros & Cons

In general, this flow makes our benchmarking results a bit more reproducible and reliable by mitigating most of [the downsides of across versions flow](#downsides). However, it has some negative consequences too:

* Rerunning benchmarks with a large amount of cases takes significantly time (slower feedback loop!).
* It yields more complex benchmarking code, which makes it hard to iterate on, and spot places where you benchmark the testing code vs the portion of the code you wanted to.
* For continuous production use, it does not make sense to commit that benchmark with all cases, which are no longer being continued. It fits better to capture such a benchmark in some remote branch for future reference though.

## Summary

To sum up, the new `benchstat` version with projection feature enables local probing of [OLAP](https://en.wikipedia.org/wiki/Online_analytical_processing) type of questions against your benchmarking results. 

As with everything, the two presented flows (across [versions](#old-school-flow--comparing-efficiency-across-versions) and [cases](#newly-enabled-flow--comparing-efficiency-across-cases)) represent different trade-offs. None of those is objectively better or worse. I would recommend considering using both in a hybrid approach, depending on your goals.

In the mentioned [example](#example), I found the `across case` flow more beneficial for the real scenario Remote Write protocol benchmark. This is because the Prometheus code already supports multiple sample batches, and the implementations for different compressions and encoders were easily imported. We also have to support both the 1.0 and 2.0 protocol versions, so they already co-exist in the current codebase. Furthermore, given the protocol's relative popularity I wanted to ensure everyone can reproduce the benchmarks and give feedback. All of those reasons make the [case](#newly-enabled-flow--comparing-efficiency-across-cases) flow a trivial choice here. However, from this point, if were iterating on optimizations to compression or protocol, I would likely follow [versions](#old-school-flow--comparing-efficiency-across-versions) flow a bit.

Hopefully, at this point, you know what flow to use for what benchmarking needs in your engineering adventures! You are also welcome to check other useful `benchstat` options e.g. I recently used the `-format csv` option to get my comparisons into Google Sheets, so I can produce charts for [my talk slides](https://docs.google.com/presentation/d/132Pk1dDXh0LazigEGoY9AYHmWzh4-ntZvPWJ7twV3Oc/edit#slide=id.g2fe2a676c3e_0_2). I also found asking `Gemini` GenAI for chart rendering pretty useful and accurate, but old-good way still gives a bit more deterministic control on small details.

Finally, no matter what flow you will use, follow [the proposed case syntax](https://go.googlesource.com/proposal/+/master/design/14313-benchmark-format.md#:~:text=We%20propose%20that%20sub%2Dbenchmarks%20adopt%20the%20convention%20of%20choosing%20names%20that%20are%20key%3Dvalue%20pairs%3B%20that%20slash%2Dprefixed%20key%3Dvalue%20pairs%20in%20the%20benchmark%20name%20are%20treated%20by%20benchmark%20data%20processors%20as%20per%2Dbenchmark%20configuration%20values.). No harm in doing so, and you never know when somebody might want to use `benchstat` projection for your benchmarks!

Last, but not least, I am here to learn too, so feel free to give feedback on what I could explain or do better! 🤗

### Credits

As always, thanks to all reviewers (e.g. David, Manik!) and [Maria Letta for the beautiful Gopher illustrations](https://github.com/MariaLetta/free-gophers-pack).
