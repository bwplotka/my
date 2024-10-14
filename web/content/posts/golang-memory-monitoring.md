---
weight: 10
authors:
- name: "Bartek Płotka"
date: 2019-06-08
linktitle: What to expect when monitoring memory usage for modern Go applications
type:
- post 
- posts
title: What to expect when monitoring memory usage for modern Go applications.
categories:
- go
- infra
- efficiency
---

> EDIT (2020.12.13): From Go 1.16, Go on Linux moves back to using `MADV_DONTNEED` when releasing memory. However, this blog post
> still applies in terms of how to monitor memory consumption, although we should see less memory cached by Go runtime. See [this issue](https://github.com/golang/go/issues/42330).

**TL;DR: Applications build with Go 1.12+ reports higher RSS memory usage on Linux. 
This does not mean that they `require` more memory, it's just optimization for cases where there is no other memory
pressure. This is especially visible inside a container.**

Go has a strict [release timeline](https://github.com/golang/go/wiki/Go-Release-Cycle) to reduce the risk
of bugs on releases. Three months code freeze gives a lot of time for documenting, testing, benchmarking and fixing bugs.
As a result, at work and in the open source projects I maintain, we usually upgrade our Go version soon(-ish) after release with no fear. 

In February the Go team released [1.12 version of Go](https://golang.org/doc/go1.12) and it is **not** an exception to this rule either,
it is *roughly* stable, but with a minor caveat:
 
### From outside memory usage / RSS for apps built with Go 1.12+ can look like a memory leak...

To showcase this behavior, let's take an example Go application running in a Kubernetes container. 
Because I have been working on improving the [remote read protocol](https://docs.google.com/document/d/1JqrU3NjM9HoGLSTPYOvR217f5HBKBiJTqikEB9UiJL0/edit#) for the [Prometheus](https://prometheus.io) project, I will take Prometheus's memory consumption
as reported by [cadvisor](https://github.com/google/cadvisor) during my load testing. 

Let's look at the most popular metric for Kubernetes containers: `container_memory_usage_bytes`. 
It's used in many popular Grafana dashboards that show the utilization of pod/container resources. 
It is also heavily used in alerting, to proactively alert on memory saturation, although one can argue that you should not alert on root causes, but on symptoms (:

Let's see the memory usage for exactly the same load test performed on Prometheus built with Go 1.11 and Go 1.12.5.
 
![RSS of the container running Prometheus built with Go 1.11 during test](/images/blog/go-memory-monitoring/1.png)

As far as I can tell this makes sense from my understanding of the current implementation of what I am testing, although the consumption feels a bit "laggy".

![RSS of the container running Prometheus built with Go 1.12.5 during test](/images/blog/go-memory-monitoring/2.png)

Compared to the result with Go 1.11 you need to admit that the first impression for Go 1.12.5 is quite negative, right? Memory usage is increasing without ever coming down. 
Initially, this might look like a leak or some bug in memory allocation. Even worse it looks like the container is just about to run out of memory (OOM).

When taking a closer look, all those assumptions are actually proven wrong. In my case, the container is not even close to OOM, and it is actually more performant ([in theory](https://github.com/golang/go/issues/23687#issuecomment-496705293)). 

### Go 1.12 memory optimizations affect the reported memory usage / RSS in certain cases. What changed and why?

The change responsible for this effect is roughly explained in the release notes for the [Go runtime](https://golang.org/doc/go1.12#runtime)::

> On Linux, the runtime now uses MADV_FREE to release unused memory. This is more efficient but may result in higher reported RSS. The kernel will reclaim the unused data when it is needed. To revert to the Go 1.11 behavior (MADV_DONTNEED), set the environment variable GODEBUG=madvdontneed=1.

As you probably know Go has quite sophisticated [GC mechanisms](https://blog.golang.org/ismmkeynote0) which are 
responsible for freeing allocated memory whenever a piece of data is no longer referenced by your code.
The key part for our issue is that processes can release allocated memory in many different ways. 
Those ways also vary per OS and kernel version.  
Among many options the Go runtime in certain cases uses [`madvise`](http://man7.org/linux/man-pages/man2/madvise.2.html) system call. One of the many advantages
of `madvise` is that Go processes can closely **cooperate** with the kernel on how to treat certain "pages" of RAM memory in virtual space in a way that helps both sides.

This cooperation is mutually beneficial, as programs generally use memory in a highly dynamic way. Sometimes they allocate more, sometimes less. 
Since asking the kernel for free memory pages is sometimes quite expensive, doing that back and forth can take time and resources.
On the other hand, we cannot just keep the memory reserved, as it can lead to the machine OOMing (kernel panic) or swapping to disk (extremely slow)
if suddenly other processes require more memory. Memory is a non-compressible resource so we need something in the middle: releasing by advising.

Thanks to `madvise` we can mark some memory pages as "not used, but might be needed soon". 
I don't think that it is the professional name for this approach, but let's call it "cached memory pages" for the purpose of this blog.

**This approach affects the amount of memory occupied by a process as registered by the  kernel. Those "cached" pages are still technically reserved for the Go process, 
even though the kernel can use them as soon as it needs memory for other processes**

From a high-level perspective the `madvise` system call consists of 3 arguments:

* `address` and `length` that define what memory range this call refers to.
* `advice` that says what to advice for those memory pages.

`advice` can have many different values depending on the specific OS and kernel version used by the system on which the Go process is running.

To explain the Go 1.12 change, we are interested in two specific values:

* `MADV_DONTNEED`

  > Do not expect access in the near future. (For the time being, the application is finished with the given range, so the kernel can free resources associated with it.)

* `MADV_FREE` (since Linux kernel 4.5)

  >  The application no longer requires the pages in the range
     specified by addr and len.  The kernel can thus free these
     pages, but the freeing could be delayed until memory pressure
     occurs.  (...)

In essence Go 1.11 was mostly using `MADV_DONTNEED` whereas Go 1.12 where possible uses `MADV_FREE`. As you can read in the descriptions above, the latter
tells the kernel to not free resources associated with the given range until memory pressure occurs. Memory pressure means 
that other processes or the kernel itself do not have enough memory in the unused pool to satisfy their needs.

In my opinion, this change makes a lot of sense, especially in a Kubernetes/container environment, where the general pattern is to use a single process per container. 
Since memory limits are enforced on a per container basis, releasing memory immediately for the only process that is running inside of it is mostly wasted work.

Having the Go process using exclusively 100% of memory specified in the limits can be beneficial for overall container workload performance. However as you've seen, it 
makes monitoring a bit more difficult.

### The Go runtime is reluctant to give memory pages back, so how can I monitor *actual* usage?

First of all, what does "actual memory usage" mean? In my opinion, from the monitoring side we care about two things:

* The application perspective: How much we do allocate and where (heap vs stack etc).

Here we are quite lucky as Go gives a handful of metrics. With the Prometheus client enabled they all look like this (during the same test as at the beginning of this blog post):

![in-use memory of Prometheus from the Go runtime's perspective during test](/images/blog/go-memory-monitoring/3.png)

All those metrics are fetched without alterations from [runtime.MemStats](https://golang.org/pkg/runtime/#MemStats)

NOTE: The in-use memory does NOT include `mmap` files and memory allocated by CGO.

* THe machine perspective: in-use memory saturation that leads to a machine's kernel crashing (OOM) or the process becoming extremely slow (swap if enabled). 

This is more tricky. Let's focus on the container here. Cadvisor exposes a container's memory metrics straight from the [cgroup memory controller](https://www.kernel.org/doc/Documentation/cgroup-v1/memory.txt) counters 
([code](https://sourcegraph.com/github.com/google/cadvisor@cc445b9cc7e20e12062cc40ac0aa2b88c40dc487/-/blob/container/libcontainer/handler.go#L533))

As you remember `container_memory_usage_bytes` was not very useful. Essentially you never know if memory is saturated or just cached.
Even worse, the `usage_in_bytes` cgroup counter is quite approximative. From the [cgroup docs](https://www.kernel.org/doc/Documentation/cgroup-v1/memory.txt):

> For efficiency, as other kernel components, memory cgroup uses some optimization
  to avoid unnecessary cacheline false sharing. usage_in_bytes is affected by the
  method and doesn't show 'exact' value of memory (and swap) usage, it's a fuzz
  value for efficient access. (Of course, when necessary, it's synchronized.)
  If you want to know more exact memory usage, you should use RSS+CACHE(+SWAP)
  value in memory.stat(see 5.2).
  
There is `container_memory_rss` but it behaves similarly due to `MADV_FREE` behavior.

The only promising metric is `container_memory_working_set_bytes` recommended in various comments. It generally behaves similarly to `container_memory_usage_bytes`:

![container_memory_usage_bytes vs container_memory_working_set_bytes for Prometheus Go 1.12.5 during test](/images/blog/go-memory-monitoring/5.png)

However, keep in mind that `container_memory_working_set_bytes` (WSS) is not perfect either. This is because it literally takes the fuzzy, not exact `container_memory_usage_bytes` and subtracts
the value from `total_inactive_file` counter which is a `number of bytes of file-backed memory on the inactive LRU list.`.

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
of memory bytes being a value that would OOM the kernel or exceed the limit for container cgroup. However, I definitely do not know exactly how close it gets to reality (: 

If you know a better way for monitoring/alerting on memory saturation let me know! (:

Note that cadvisor `container_memory_working_set_bytes` and other metrics can have totally different update intervals to e.g 
`go_memstats_alloc_bytes`. So don't be surprised to see higher allocations spikes than with `container_memory_working_set_bytes` for a short time as 
observed [here](https://github.com/google/cadvisor/issues/2242)

### Bonus experiment; what happens on memory pressure?

`container_memory_usage_bytes` went high during my test. Since the system did not experience any memory pressure it stayed near the memory limit of my container as defined by

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

I was curious. If the above explanation of high RSS is true, then would I be able to run a memory intensive process in the same container as Prometheus, 
despite a high RSS due to "cached" pages?

So I exec-ed into the container and ran `yes | tr \\n x | head -c $BYTES | grep n` with a 4GB value. I know that there are nice tools like 
[stress](https://people.seas.harvard.edu/~apw/stress/), but I was lazy and the Prometheus container is built with `busybox` and with a `NOBODY` user.
Hence I could not install anything leading to my use of `grep` to allocate 4GB memory (: 

![RSS and WSS for Prometheus Go 1.12.5 after test + memory preassure](/images/blog/go-memory-monitoring/9.png)

Since usage stated 8GB before I ran the command and the container limit is set to 10GB, the kernel first used the remaining free 2GB but then ran into 
on memory pressure. The kernel then had to use ~2GB of "cached" memory pages from 
Prometheus. The lower value for container memory usage once my grep command terminated confirms that behaviour as it indeed freed up a total of 4GB.

To sum up, this experiment confirms that most of the bytes reported by RSS / memory usage are reusable, so be careful.

### Conclusions

Go 1.12.5 works well but makes it a bit more difficult to monitor saturation, as happens with any additional complex, low-level optimizations involving the kernel.

This post was written as a response to the confusion the new Go memory management caused. I have seen and heard many questions around this on the [Thanos](https://thanos.io) slack channel and while talking with people at KubeCon EU 2019.
More and more applications will be released with Go 1.12.5 so be prepared. Open source projects I maintain and help with like [Thanos](https://thanos.io), TSDB and Prometheus already use Go 1.12.5 in their new releases.

So:

* If you depend on `container_memory_usage_bytes` switch to `container_memory_working_set_bytes` metric for closest possible experience to actual usage. It's not perfect though.
* Use `go_memstats_alloc_bytes` and others (e.g `go_memstats_.*_inuse_bytes`) to see actual allocations. Useful when profiling and optimizing your application memory. This helps to filter out the memory that is "cached" and it's the most accurate from the application perspective.
* Avoid `Go 1.12.0-1.12.4` due to a memory [allocation slowness bug](https://github.com/kubernetes/kubernetes/issues/75833#issuecomment-487830238) 
* Do not be afraid to update the Go runtime version in your application. But when you do:
  * Read the changelog
  * Change JUST the version (: Change a single thing at a time to ensure that if there is something suspicious, you can immediately narrow down to the Go runtime upgrade.  

BTW if you are new to memory management and you would love to know even more details I would recommend reading the blog post of my friend [@povilasv: "Go memory management"](https://povilasv.me/go-memory-management/)
