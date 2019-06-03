---
authors:
- name: "Bartek Płotka"
date: 2019-06-03
linktitle: Be careful when monitoring memory usage for Golang application just gets.
type:
- post 
- posts
title: Be careful when monitoring memory saturation for Golang applications
readingTime: 15
weight: 1
series:
- thanos
---

In February Golang team released [1.12 version of Golang](https://golang.org/doc/go1.12). From my experience, Golang releases are usually stable that's
why at my work and on the open source projects I maintain we happily build our applications with newer Golang version soon-ish after release.
Definitely not in the same day, mostly if there is some motivation, like finally consistent `context` package, go modules, tools improvements, the things is,
we never even ask "is it stable?".

And guess what, Golang 1.12 is not an exception here. It is roughly stable. 
With minor caveat... memory usage for the Golang process reported by Linux kernels skyrockets and gets less stress tolerant SREs an heart attack :heart: :gun: (: 

### From outside memory usage for apps built with Golang 1.12+ can look like memory leak

Essentially with Prometheus and Kubernetes  the tendency is to use 
are hooked into `` when you use typical "blackbox" metric for memory used

This is due to one of many changes done in [runtime](https://golang.org/doc/go1.12#runtime):

```
On Linux, the runtime now uses MADV_FREE to release unused memory. This is more efficient but may result in higher reported RSS. The kernel will reclaim the unused data when it is needed. To revert to the Go 1.11 behavior (MADV_DONTNEED), set the environment variable GODEBUG=madvdontneed=1.
```



`GODEBUG=madvdontneed=1`

https://github.com/golang/go/issues/23687


container_memory_usage_bytes

container_memory_working_set_bytes


### Conclusions

* Use `go_memstats_alloc_bytes` metric if possible it the most accurate from application perspective.
* Do not afraid to update Golang runtime version in your application. But when you do:
  * Read the changelog
  * Change JUST the version (: Change single thing at the time to ensure that if there is something suspicious, you can immediately narrow to Golang runtime upgrade.
  

<!--- Notes 

https://github.com/prometheus/prometheus/issues/5524 bug Golang 1.12.5
cgroupfs memory working set: https://github.com/google/cadvisor/issues/1529#issuecomment-287477580

IPFS "Go mem runtime" relunctant to give away memory" https://github.com/ipfs/go-ipfs/issues/3318#issuecomment-426884170

!!! https://github.com/golang/go/issues/23687#issuecomment-496705293

Ref: https://blog.freshtracks.io/a-deep-dive-into-kubernetes-metrics-part-3-container-resource-metrics-361c5ee46e66
You might think that memory utilization is easily tracked with container_memory_usage_bytes, however, this metric also includes cached (think filesystem cache) items that can be evicted under memory pressure. The better metric is container_memory_working_set_bytes as this is what the OOM killer is watching for.

https://stackoverflow.com/questions/28244595/which-fields-in-memstats-struct-refer-only-to-heap-only-to-stack
What am I missing? 
WSS 475MB
heap inuse, alloc?, mcache, mspan, stack = 375MB
without alloc: 292 MB
These fields do not include numbers for goroutine stacks, so CGO (as it is not operate by Go runtime!)
MMAP! 121585664 = 115.953125 MB


cat /sys/fs/cgroup/memory/memory.stat 
cache 275980288
rss 9850789888
rss_huge 991952896
shmem 0
mapped_file 121585664
dirty 0
writeback 0
swap 0
pgpgin 2334581
pgpgout 281245
pgfault 2364500
pgmajfault 0
inactive_anon 0
active_anon 451702784
inactive_file 9674686464
active_file 315392
unevictable 0
hierarchical_memory_limit 10737418240
hierarchical_memsw_limit 10737418240
total_cache 275980288
total_rss 9850789888
total_rss_huge 991952896
total_shmem 0
total_mapped_file 121585664
total_dirty 0
total_writeback 0
total_swap 0
total_pgpgin 2334581
total_pgpgout 281245
total_pgfault 2364500
total_pgmajfault 0
total_inactive_anon 0
total_active_anon 451702784
total_inactive_file 9674686464 = 9226.5 MB # # of bytes of file-backed memory on inactive LRU list.
total_active_file 315392
total_unevictable 0

usage: 10149810176
WSS: 475115520 = usage - total_inactive
Sys (the synonim of RSS) https://stackoverflow.com/questions/24863164/how-to-analyze-golang-memory

Idle heap: 9314287616

https://povilasv.me/go-memory-management/ SPANS
https://povilasv.me/prometheus-go-metrics/ inuse > alloc

https://stackoverflow.com/questions/1984186/what-is-private-bytes-virtual-bytes-working-set working sets -> pages touched 
recently by process

https://github.com/google/cadvisor/blob/master/info/v1/container.go#L367

https://sourcegraph.com/github.com/google/cadvisor@cc445b9cc7e20e12062cc40ac0aa2b88c40dc487/-/blob/container/libcontainer/handler.go#L533

For efficiency, as other kernel components, memory cgroup uses some optimization
to avoid unnecessary cacheline false sharing. usage_in_bytes is affected by the
method and doesn't show 'exact' value of memory (and swap) usage, it's a fuzz
value for efficient access. (Of course, when necessary, it's synchronized.)
If you want to know more exact memory usage, you should use RSS+CACHE(+SWAP)
value in memory.stat(see 5.2).
https://www.kernel.org/doc/Documentation/cgroup-v1/memory.txt
---!>

