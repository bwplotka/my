---
authors:
- name: "Bartek Płotka"
date: 2019-06-03
linktitle: What to expect when monitoring memory usage for modern Golang application
type:
- post 
- posts
title: What to expect when monitoring memory usage for modern Golang application.
weight: 1
categories:
- golang
---

In February Golang team released [1.12 version of Golang](https://golang.org/doc/go1.12). From my experience, Golang releases are usually stable that's
why at my work and on the open source projects I maintain we happily build our applications with newer Golang version soon-ish after release.
Definitely not in the same day, mostly if there is some motivation, like finally consistent `context` package, go modules, tools improvements, the things is,
we never even ask "is it stable?"

And guess what, Golang 1.12 is not an exception here. It is roughly stable. 
With minor caveat... memory usage for the Golang process reported by Linux kernels (e.g RSS) 
skyrockets and gets less stress tolerant SREs an heart attack :heart: (: 

### From outside memory usage for apps built with Golang 1.12+ can look like memory leak

Let's take an example Golang application in the Kubernetes container. Since in my free time I am working on improving remote read protocol of Prometheus, let's see Prometheus memory consumption 
reported by [cadvisor] during some load test. In this case I have built Prometheus with Golang 1.11 to show pre 1.12 situation:

We are looking on the most popular metric `container_memory_usage_bytes` that is well used in many popular Grafana dashboards that shows utilization of different pod/container resources. 
Be aware that `container_memory_usage_bytes` is heavily used in alerting as well to alert on memory saturation, although one can argue that you should not alert on root causes, but on symptoms (:

![RSS of container running Promethues built with Go 1.11 during test.](/images/blog/go-memory-monitoring/1.png)

As far as I can tell makes make sense from my the current implementation of what I am testing, although the consumption feels bit "laggy", but we will touch in this later.

Now let's build Prometheus with Golang 1.12.5 and run exactly the same test suite.

![RSS of container running Promethues built with Go 1.12.5 during test](/images/blog/go-memory-monitoring/2.png)

First impression is leak or some bug in memory allocation. "Most likely container is on the edge of OOM."

All those assumptions are wrong, it's just the Golang 1.12 memory runtime improvements behaves different that can cause confusion.

### What changed and why?

Because in our test we changed only Golang version it's clearly something on the edge of 1.11 and 1.12

The change responsible for this behaviour is roughly explained in [runtime](https://golang.org/doc/go1.12#runtime) release notes:

> On Linux, the runtime now uses MADV_FREE to release unused memory. This is more efficient but may result in higher reported RSS. The kernel will reclaim the unused data when it is needed. To revert to the Go 1.11 behavior (MADV_DONTNEED), set the environment variable GODEBUG=madvdontneed=1.

Processes can release allocated memory in different ways. Among many options Golang runtime in some cases uses [madvise](http://man7.org/linux/man-pages/man2/madvise.2.html) system call.
As you know Golang has quite sophisticates GC mechanism that allow Golang developer to not think about releasing and memory ownership during development (in theory (:). One of many advantage 
of `madvise` is that Golang process can cooperate with Linux kernel better on how to treat certain "pages" of the RAM memory in virtual space in a way that helps both sides.

`madvise` in high level consists of 3 arguments:

* `address` and `length` that defines what memory range this call refers to.
* `advice`

The advice can have many values like e.g `MADV_WILLNEED` which is essentially "Yo kernel - I will access this space soon".

In this case we are really interested in those two:

`MADV_DONTNEED`

> Do not expect access in the near future. (For the time being, the application is finished with the given range, so the kernel can free resources associated with it.)


If you are new to the memory management and you would love to know the details I would suggest reading blog of my friend [@povilasv: "Go memory management"](https://povilasv.me/go-memory-management/)


So Jimmy as many other users looked up and found [cadvisor] project that gives performance metrics for containers! More specifically shiny [`container_memory_usage_bytes`](https://github.com/google/cadvisor/blob/da29418c31e5d4d0f33640aeafa7c5487f039630/info/v1/container.go#L342) that is documented
as this is cadvisor project:

```go
	// Current memory usage, this includes all memory regardless of when it was
	// accessed.
	// Units: Bytes.
	Usage uint64 `json:"usage"`
``` 

As the name of the metric is catchy and it kind of looks alright Jimmy configured the mentioned dashboards to use that, so then when performing some benchmarks on two 1.11 Golang applications running in containers, he can
see the memory consumption like this:



However Jimmy cannot use that metric in his dashboards for container/pods resource usage due to three reasons:
* it's rarely the case (unfortunately) that every container running on Jimmy's cluster is a Golang application, so he needs some container memory consumption metric that is agnostic to the processes running inside. 
* In Kubernetes we can set CPU and memory limits only per container (not per process), so container memory metric sounds more useful here.
* Sure, Jimmy keep just one process per container, but still, container guest kernel can see the memory in different way then what Golang is counting in runtime. 






`GODEBUG=madvdontneed=1`

https://github.com/golang/go/issues/23687


container_memory_usage_bytes

container_memory_working_set_bytes


### Conclusions

* Use `go_memstats_alloc_bytes` metric if possible it the most accurate from application perspective.
* Do not afraid to update Golang runtime version in your application. But when you do:
  * Read the changelog
  * Change JUST the version (: Change single thing at the time to ensure that if there is something suspicious, you can immediately narrow to Golang runtime upgrade.
  
