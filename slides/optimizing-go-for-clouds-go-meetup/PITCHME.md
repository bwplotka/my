@snap[north span-100]
![width=300](assets/images/GopherSpaceCommunity.png)

#### Optimizing Go for Clouds (and beyond @emoji[rocket])
#### _Practical Intro_
@snapend

@snap[south-east padded snap-100 text-04 text-italics text-right]
London, UK | 17.06.2020 | [London Gophers Meetup](https://www.meetup.com/LondonGophers/events/270419925/) | [Bartłomiej Płotka](https://bwplotka.dev) 
@snapend

Note:

https://www.meetup.com/LondonGophers/events/270419925/
Introduction:
I am PSWE, however SRE, in our job we build services. Parts of bigger systems usually running on K8s.
There is pressure on scaling but applications themselves have lots of overhead.
Go is popular for cloud-native applications. We will focus on cloud-native applications as usual, we don't want to go into extremes. We don't need extreme efficiency. We just want to avoid leaks and silly allocations/CPU waste. This is to save money and putting scalability complexity when not needed. We also care about readability!
challenges: NO one really gives real demos, takes time, context switching, easy to make wrong assumptions. Example: https://github.com/thanos-io/thanos/pull/2603
How to approach it?
Always start simple. Never micro optimize.
Two main categories (for simplicity, there are others like network/IO). Usually optimizing
 means:
Reducing unnecessary wor
 balancing between those two.
CPU (Compressible and what it means)
Memory
HOW to tell what is bottleneck? How to tell we can do anything? Measure dataset vs actual resources usage (e.g lookup 100B on large index is using 12GB?)
Focus on whats your main bottlenecks. Gather data first. Is your server CPU or Memory sensitive? Will it timeout of OOM first? This will tell us where we can make some tradeoffs. Stateful (e.g. DB) vs  stateless applications (e.g. proxy).
Measure, optimize, measure and compare again. Repeat.
Measuring
Micro benchmarks (go test -bench) vs e2e benchmarks (e.g feedback from e.g cgroups/OS/go metrics.
Writing test is a challenge. It’s very tempting to write benchmark spanning huge logic, for example whole complicated query request inDB. This is hard there are too many moving parts. It’s much easier to start with smaller things
Understading. The more test you will write, better, the more runs, better
Profiling
When to use each of those.
Optimizing
CPU: Will explain basic issues: (recursiveness, no sleep between wait loops, starvations, etc.
Memory: basic pitfalls, mmap and why it's not really safe.
Summary:
Useful tools benchstat, funcbench, leaktest, etc.
Takeaways.     https://github.com/alecthomas/unsafeslice/blob/master/unsafeslice.go
  
---
@snap[north span-95 text-left]
#### Agenda
@snapend

@snap[midpoint span-75 text-07 text-bold text-left]
@ol[list-fade-fragments](true)
1. In scale, do we even care about performant code? @note[Something]
1. How to approach and when to optimize things?
1. Data Driven Decisions: How to measure performance.
1. Optimization tricks & pitfalls
@olend

@snapend

Note:

TBD

---?include=slides/common/whoami-go/PITCHME.md

---
@snap[north span-95 text-left]
#### Summary
@snapend

@snap[midpoint span-75 text-07 text-bold text-left]
@ol[](false)
* Amazing [ashleymcnamara gophers](https://github.com/ashleymcnamara/gophers)
@olend

---?include=slides/common/thank-you/PITCHME.md

---
@snap[north span-95 text-left]
#### Credits
@snapend

@snap[midpoint span-75 text-07 text-bold text-left]
@ol[](false)
* Amazing [ashleymcnamara gophers](https://github.com/ashleymcnamara/gophers)
@olend


