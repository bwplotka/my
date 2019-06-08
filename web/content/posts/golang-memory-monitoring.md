---
authors:
- name: "Bartek Płotka"
date: 2019-06-03
linktitle: What to expect when monitoring memory usage for modern Golang applications
type:
- post 
- posts
title: What to expect when monitoring memory usage for modern Golang applications.
weight: 1
categories:
- golang
---

**TL;DR: Applications build with Golang 1.12+ reports higher RSS memory usage on Linux. 
This does not mean that they `require` more memory, it's just optimization for cases when there is no other memory 
pressure. This is especially visible inside container.**

Golang has strict [release timeline](https://github.com/golang/go/wiki/Go-Release-Cycle) to reduce risk 
of bugs on releases. Three months :grey_exclamation: code freeze gives a lot of time for documenting, testing, benchmarking and fixing bugs.
As a result, at work and in the open source projects I maintain, we usually upgrade Golang version soon(-ish) after release with no fear. 

In February Golang team released [1.12 version of Golang](https://golang.org/doc/go1.12) and it's **not** an exception,
it is *roughly* stable.
 
With minor caveat.
 
*Memory usage for the Golang process reported by Linux kernel (e.g RSS) 
skyrockets and can scare SREs/ops/devs (:*

### From outside memory usage for apps built with Golang 1.12+ can look like memory leak

To showcase this behaviour, let's take an example Golang application running in the Kubernetes container. 
Because this month in my free time I am working on improving remote read protocol for [Prometheus](https://prometheus.io) project, let's see Prometheus memory consumption 
reported by [cadvisor](https://github.com/google/cadvisor) during my load test. 

Let's look on the most popular metric for Kubernetes containers: `container_memory_usage_bytes`. 
It's well used in many popular Grafana dashboards that shows utilization of pod/container resources. 
`container_memory_usage_bytes` is also heavily used in alerting, to proactively alert on memory saturation, although one can argue that you should not alert on root causes, but on symptoms (:

Let's see results with exactly the same load test performed on Prometheus built with Golang 1.11 and Golang 1.12.5.
 
![RSS of container running Promethues built with Go 1.11 during test.](/images/blog/go-memory-monitoring/1.png)

As far as I can tell makes make sense from my the current implementation of what I am testing, although the consumption feels bit "laggy", but we will touch this later.

![RSS of container running Promethues built with Go 1.12.5 during test](/images/blog/go-memory-monitoring/2.png)

You need to admit that first impression is quite negative, right? Memory usage is getting super high leak stays there. 
Initially it can look like a leak or some bug in memory allocation. Even worse it looks like container is just about to OOM.

All those assumptions are wrong. It's correct and it makes your application more performant ([in theory](https://github.com/golang/go/issues/23687#issuecomment-496705293)). 

### Golang 1.12 memory optimizations alters memory usage / RSS behaviour in certain cases. What changed and why?

The change responsible for this effect is roughly explained in [runtime](https://golang.org/doc/go1.12#runtime) release notes:

> On Linux, the runtime now uses MADV_FREE to release unused memory. This is more efficient but may result in higher reported RSS. The kernel will reclaim the unused data when it is needed. To revert to the Go 1.11 behavior (MADV_DONTNEED), set the environment variable GODEBUG=madvdontneed=1.

As you know Golang has quite sophisticated [GC mechanism](https://blog.golang.org/ismmkeynote0) that allow Golang developer to not think about releasing and memory 
ownership during development (well, thinking is still useful :smile: ). The key part for our issue is that processes can release allocated memory in many different ways. Those ways also depend on OS and kernel versions.  
Among many options Golang runtime in certain cases uses [`madvise`](http://man7.org/linux/man-pages/man2/madvise.2.html) system call. One of many advantages
of `madvise` is that Golang process can **cooperate** with Linux kernel closely on how to treat certain "pages" of the RAM memory in virtual space in a way that helps both sides.

*Why not just simply return memory pages back to kernel pool without advising?*

Well, because programs uses memory dynamically. Sometimes they allocate more, sometimes less. Since asking kernel for free memory pages is sometimes quite expensive, doing that back and forth can take time and resources.
And why to even do that when It's often the case that other processes in the same machine does not really need that memory currently, but they might need at some point.

Thanks to `madvise` we can mark some memory pages as "not used, but if kernel really needs that memory back it can take it straight away. If not, Golang will reuse it if needed".

**This affects the memory occupied counter in kernel. It's because those pages that are "not used, but it's nice to have them just in case" are still technically reserved by Golang process, even though kernel will use it as soon as it needs memory for other processes**

We can compare this to the office with limited number of pens. Let's say one worker is finishing one pen per hour, so it grabs literally all available pens and puts on desk next to him to efficiently continue the work.
It does not mean that he owns all of those pens. If any other work has to reuse pen it can go to desk and grab some. However if no one needs the pens stays close to the heavy pen user.

### Golang

In details `madvise` system call in high level consists of 3 arguments:

* `address` and `length` that defines what memory range this call refers to.
* `advice` that's says what to advice for those memory pages.

`advice` can have many different values depending on OS and kernel version e.g `MADV_WILLNEED` which is essentially "Yo kernel - I will access this space soon".

To explain Golang 1.12 change, we are interested in those two:

* `MADV_DONTNEED`

  > Do not expect access in the near future. (For the time being, the application is finished with the given range, so the kernel can free resources associated with it.)

* `MADV_FREE` (since kernel 4.5)

  >  The application no longer requires the pages in the range
     specified by addr and len.  The kernel can thus free these
     pages, but the freeing could be delayed until memory pressure
     occurs.  (...)

In the essence Golang 1.11 was based mostly on `MADV_DONTNEED` whereas Golang 1.12 if possible uses `MADV_FREE`.




If you are new to the memory management and you would love to know the details I would recommend reading blog of my friend [@povilasv: "Go memory management"](https://povilasv.me/go-memory-management/)

### Conclusions

* Use `go_memstats_alloc_bytes` metric if possible it the most accurate from application perspective.
* Do not afraid to update Golang runtime version in your application. But when you do:
  * Read the changelog
  * Change JUST the version (: Change single thing at the time to ensure that if there is something suspicious, you can immediately narrow to Golang runtime upgrade.
  
