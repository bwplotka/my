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

1. Creating one a `func BenchmarkXYZ(b *testing.B)` function, with or without [`b.Run(...)`](https://pkg.go.dev/testing#B.Run) cases that benchmarks a portion of your code.
2. Running that benchmark, ideally at least 6 times (`-count 6`) so outlier detection can do its work (tell you when your results are widely different, thus less reliable) and save the results to e.g. `old.txt` file.
3. You can then git commit whatever you had (just to not get lost!), change the code you are benchmarking (e.g. in an attempt to optimize it based on previously gathered profiles) and execute the same benchmark to produce new numbers e.g. in `new.txt` file.
4. Run `benchstat old.txt new.txt` or `benchstat base=old.txt new=new.txt` (for nice headers) to compare `old.txt` with `new.txt`. You will see the absolute latency, allocations (and any custom metrics you reported) numbers, but also the relative percentages of improvements/regressions for those, and the probability of noise.

I wrote a quick [example benchmark](<todo>)


> Example benchstat result across results in different files. Note that `bytes/message` is a custom metric :
> 
```
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

After those steps you likely know if new changes improved CPU latency or memory consumption or made it worse, or if you have to repeat (or fix!) the benchmark due to noise.

### Benefits

There are reason why this method is a default way people microbenchmark.

* It's simple, especially for an interactive quick benchmarking session, where you run a quick benchmark and you don't intend to reuse the benchmarking code for later, or by others.
* Does not require complex benchmarking code and gets you started and learn about efficiency of your code fast. It is true, that the more complex benchmark is, the more mistakes we can make to measure wrong things (e.g. measuring benchmark code vs the actual code or measuring code that yields wrong results.

### Downsides

There are cases where this flow is not the most optimal. Let's enumerate some limitations:

* It's easy to get lost in changes. Especially if you forget about git versioning properly, it's get easy to track what exactly you benchmark, especially if you notice you ideas are not helping and you need to revert to some local minimum state.
* It's easy to accidentally change benchmark itself in a different version. This makes it highly unreliably to compare results across those, especially if you don't notice benchmark changes. If you notice them, it's painful to retro-fit new benchmark code with older code you want to benchmark to have proper `old.txt` results.
* Microbenchmarks, 


Problems: What if you iterate longer? (binary? Dave wrote? git commit? permutations? reproducibility by others)

## Newly enabled flow: Comparing efficiency across cases

TL;DR use <param>=<value> as a case.



## Summary

Across version comparison is not worse or better, but
* CSV!


