---
authors:
- name: "Bartek Płotka"
date: 2019-06-08
linktitle: What to expect when monitoring memory usage for modern Go applications
type:
- post 
- posts
title: What to expect when monitoring memory usage for modern Go applications.
weight: 1
categories:
- go
---

**TL;DR: Applications build with Go 1.12+ reports higher RSS memory usage on Linux. 
This does not mean that they `require` more memory, it's just optimization for cases when there is no memory
pressure. This is especially visible inside a container.**

Go has a strict [release timeline](https://github.com/golang/go/wiki/Go-Release-Cycle) to reduce the risk
of bugs on releases. Three months code freeze gives a lot of time for documenting, testing, benchmarking and fixing bugs.
As a result, at work and in the open source projects I maintain, we usually upgrade Go version soon(-ish) after release with no fear. 

In February Go team released [1.12 version of Go](https://golang.org/doc/go1.12) and it is **not** an exception to this rule either,
it is *roughly* stable.
 
With a minor caveat:
 
### From outside memory usage / RSS for apps built with Go 1.12+ can look like memory leak...

To showcase this behavior, let's take an example Go application running in the Kubernetes container. 
Because this month in my free time I am working on improving [remote read protocol](https://docs.google.com/document/d/1JqrU3NjM9HoGLSTPYOvR217f5HBKBiJTqikEB9UiJL0/edit#) for [Prometheus](https://prometheus.io) project, let's see Prometheus memory consumption
reported by [cadvisor](https://github.com/google/cadvisor) during my load test. 

Let's look at the most popular metric for Kubernetes containers: `container_memory_usage_bytes`. 
It's well used in many popular Grafana dashboards that shows utilization of pod/container resources. 
`container_memory_usage_bytes` is also heavily used in alerting, to proactively alert on memory saturation, although one can argue that you should not alert on root causes, but on symptoms (:

Let's see the memory usage for exactly the same load test performed on Prometheus built with Go 1.11 and Go 1.12.5.
 
![RSS of the container running Prometheus built with Go 1.11 during test.](/images/blog/go-memory-monitoring/1.png)

As far as I can tell this makes sense from my the current implementation of what I am testing, although the consumption feels a bit "laggy".

![RSS of the container running Prometheus built with Go 1.12.5 during test](/images/blog/go-memory-monitoring/2.png)

Comparing to the previous result, you need to admit that the first impression for Go 1.12.5 is quite negative, right? Memory usage is getting super high as memory stays high and never comes back. 
Initially, it can look like a leak or some bug in memory allocation. Even worse it looks like the container is just about to OOM.

All those assumptions are wrong. In my case, the container is not even close to OOM (Out of memory signal), and it is actually more performant ([in theory](https://github.com/golang/go/issues/23687#issuecomment-496705293)). 

### Go 1.12 memory optimizations affect reported memory usage / RSS in certain cases. What changed and why?

The change responsible for this effect is roughly explained in [runtime](https://golang.org/doc/go1.12#runtime) release notes:

> On Linux, the runtime now uses MADV_FREE to release unused memory. This is more efficient but may result in higher reported RSS. The kernel will reclaim the unused data when it is needed. To revert to the Go 1.11 behavior (MADV_DONTNEED), set the environment variable GODEBUG=madvdontneed=1.

As you know Go has quite sophisticated [GC mechanism](https://blog.golang.org/ismmkeynote0) which is responsible for freeing allocated memory whenever internal data structure is not used.
 The key part for our issue is that processes can release allocated memory in many different ways. 
Those ways also depend on OS and kernel versions.  
Among many options Go runtime in certain cases uses [`madvise`](http://man7.org/linux/man-pages/man2/madvise.2.html) system call. One of the many advantages
of `madvise` is that Go process can **cooperate** with kernel closely on how to treat certain "pages" of the RAM memory in virtual space in a way that helps both sides.

This cooperation is mutually beneficial, as programs generally use memory in a highly dynamic way. Sometimes they allocate more, sometimes less. 
Since asking the kernel for free memory pages is sometimes quite expensive, doing that back and forth can take time and resources.
On the other hand, we cannot just keep the memory reserved, as it can lead to the machine OOMing (kernel panic) or swapping to disk (extremely slow)
if suddenly other processed requires it. Memory is non-compressible resource, so we need something in the middle: releasing by advising.

Thanks to `madvise` we can mark some memory pages as "not used, but might be needed soon". 
I don't think that's the professional name for this, but let's name it "cached memory pages" for the purpose of this blog.

**This approach affects the counter of memory occupied by a process in kernel. It's because those pages that are "cached" are still technically reserved by Go process, 
even though kernel will use it as soon as it needs memory for other processes**

In details `madvise` system call in high level consists of 3 arguments:

* `address` and `length` that defines what memory range this call refers to.
* `advice` that says what to advice for those memory pages.

`advice` can have many different values depending on OS and kernel version.

To explain Go 1.12 change, we are interested in those two:

* `MADV_DONTNEED`

  > Do not expect access in the near future. (For the time being, the application is finished with the given range, so the kernel can free resources associated with it.)

* `MADV_FREE` (since kernel 4.5)

  >  The application no longer requires the pages in the range
     specified by addr and len.  The kernel can thus free these
     pages, but the freeing could be delayed until memory pressure
     occurs.  (...)

In the essence Go 1.11 was based mostly on `MADV_DONTNEED` whereas Go 1.12 if possible uses `MADV_FREE`. As you can read in descriptions, the latter
tells the kernel to not free resources associated with given range until memory pressure occurs. Memory pressure means 
other process or kernel itself has not enough memory in the unused pool.

In my opinion. this change makes a lot of sense, especially in Kubernetes/container environment. When you think about it, the pattern is to use a single process per container. 
Singe the memory limits are per container as well it means that releasing memory immediately by the only process that is running on the container is mostly wasted work.

Having the Go process using exclusively 100% of memory specified in limit can be only beneficial for overall container workload performance. However as you saw, it 
makes monitoring bit more difficult.

### Go runtime is reluctant to give memory pages back, so how can I monitor *actual* usage?

First of all, what "actual memory usage" means? In my opinion, from the monitoring side we care about two things:

* Application perspective: How much we allocate and where (heap vs stack etc).

Here we are quite lucky as Go gives a handful of metrics. With Prometheus client enabled they all look like this (during the same test as in the beginning:

![in-use memory of Prometheus from Go perspective during test](/images/blog/go-memory-monitoring/3.png)

All those metrics are 1:1 fetched from [runtime.MemStats](https://golang.org/pkg/runtime/#MemStats)

NOTE: Those in-use memory does NOT include `mmap` files and memory allocated by CGO.

* Machine perspective: in-use memory saturation that leads to a machine's kernel crashing (OOM) or process being extremely slow (swap if enabled). 

This is more tricky. Let's focus on the container here. Cadvisor exposes container's memory metrics straight from [cgroup memory controller](https://www.kernel.org/doc/Documentation/cgroup-v1/memory.txt) counters 
([code](https://sourcegraph.com/github.com/google/cadvisor@cc445b9cc7e20e12062cc40ac0aa2b88c40dc487/-/blob/container/libcontainer/handler.go#L533))

As you remember `container_memory_usage_bytes` was not useful very well. Essentially you never know if memory is saturated or just cached.
Even worse `usage_in_bytes` cgroup counter was always quite fuzzy, non-exact counter, from [cgroup doc](https://www.kernel.org/doc/Documentation/cgroup-v1/memory.txt):

> For efficiency, as other kernel components, memory cgroup uses some optimization
  to avoid unnecessary cacheline false sharing. usage_in_bytes is affected by the
  method and doesn't show 'exact' value of memory (and swap) usage, it's a fuzz
  value for efficient access. (Of course, when necessary, it's synchronized.)
  If you want to know more exact memory usage, you should use RSS+CACHE(+SWAP)
  value in memory.stat(see 5.2).
  
There is `container_memory_rss` but it behaves similarly due to `MADV_FREE` behavior.

The only promising metric is `container_memory_working_set_bytes` recommended on various channels. It generally behaves similarly too `container_memory_usage_bytes`:

![container_memory_usage_bytes vs container_memory_working_set_bytes for Prometheus Go 1.12.5 during test](/images/blog/go-memory-monitoring/5.png)

However, keep in mind that it's not perfect. This is because it literally takes our fuzzy, not exact `container_memory_usage_bytes` and subtracts
value from `total_inactive_file` counter which is some magic `number of bytes of file-backed memory on inactive LRU list.`.

```go
	workingSet := ret.Memory.Usage
	if v, ok := s.MemoryStats.Stats["total_inactive_file"]; ok {
		if workingSet < v {
			workingSet = 0
		} else {
			workingSet -= v
		}
	}
	ret.Memory.WorkingSet = workingSet
```

`inactive_file` seems to include our "cached" pages *after* some time thanks to LRU logic.

Nevertheless, this seems like the only replacement of `container_memory_usage_bytes`. This is because it seems to be the closest number
of memory bytes used to the value that would OOM the kernel or exceed the limit for container cgroup. However, I am definitely missing the info how close (: 

If you know a better way for monitoring/alerting on memory saturation let me know! (:

Note that cadvisor `container_memory_working_set_bytes` and other metrics can have totally different update intervals to e.g 
`go_memstats_alloc_bytes`. So don't be surprised seeing higher allocations spikes than `container_memory_working_set_bytes` itself for a short time as 
observed [here](https://github.com/google/cadvisor/issues/2242)

### Bonus experiment; what happens on memory pressure?

`container_memory_usage_bytes` went high during my test. Since no memory pressure was on the system it was kept near the memory limit of my container as defined by

```go
corev1.ResourceRequirements{
    Requests: corev1.ResourceList{
        corev1.ResourceCPU:    resource.MustParse("1"),
        corev1.ResourceMemory: resource.MustParse("10Gi"),
    },
    Limits: corev1.ResourceList{
        corev1.ResourceCPU:    resource.MustParse("1"),
        corev1.ResourceMemory: resource.MustParse("10Gi"),
    },
},
``` 

I was curious. If the above explanation of high RSS is true, then if I would run a memory intensive process in the same container as Prometheus, 
would it be able to run despite high RSS from "cached" pages?

So I exec-ed into the container and ran `yes | tr \\n x | head -c $BYTES | grep n` with 4GB value. I know that there are nice tools like 
[stress](https://people.seas.harvard.edu/~apw/stress/), but I was lazy and Prometheus container is built with `busybox` and as `NOBODY` user,
so I could not install anything, that's why I used `grep` to allocate 4GB memory (: 

![RSS and WSS for Prometheus Go 1.12.5 after test + memory preassure](/images/blog/go-memory-monitoring/9.png)

Since usage states 8GB and limit being 10GB, the kernel on memory pressure was using as much as it can, but then he had to use ~2GB of "cached" memory pages from 
Prometheus. The resulted, lower value for container memory usage at the end confirms that logic.

To sum up, this experiment confirms that most of the bytes reported by RSS / memory usage are reusable, so be careful.

### Conclusions

Go 1.12.5 works well, but makes it a bit more difficult to monitor saturation, as any additional complex optimizations with the kernel.

* If you depend on `container_memory_usage_bytes` switch to `container_memory_working_set_bytes` metric to closest possible experience. It's not perfect though.
* Use `go_memstats_alloc_bytes` and others (e.g `go_memstats_.*_inuse_bytes`) to see actual allocations. Useful when profiling and optimizing your application memory. This helps to filter out the memory that is "cached". And it's the most accurate from the application perspective.
* Avoid `Go 1.12.0-1.12.4` due to memory [allocation slowness bug](https://github.com/kubernetes/kubernetes/issues/75833#issuecomment-487830238) 
* Do not afraid to update Go runtime version in your application. But when you do:
  * Read the changelog
  * Change JUST the version (: Change single thing at the time to ensure that if there is something suspicious, you can immediately narrow to Go runtime upgrade.  
  
BTW you are new to the memory management and you would love to know even more details I would recommend reading the blog post of my friend [@povilasv: "Go memory management"](https://povilasv.me/go-memory-management/)

