# Optimizing Go for Clouds: Practical Intro

##### Bartłomiej Płotka, London Gophers Meetup, London, 17.06.2020

<!--
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
    Takeaways.
-->
  
---

# Agenda

1. Cloud Native Programming in Go: Do we even care about performant code in "clouds"?
1. How to approach and when to optimize things?
1. DDD: Ways to measure code performance.
1. Basic optimization tricks
1. Summary

![](https://raw.githubusercontent.com/ashleymcnamara/gophers/master/GopherSpaceCommunity.png)


<!--
Let's quickly look on overview.
--> 

---

# Two column layout

This is the left column

{.column}

This is the right column

<!--
Elo
-->

---

# Slides can have images

![](https://raw.githubusercontent.com/ashleymcnamara/gophers/6603733fcf9877f166206d2414f75df72d6fd1ea/cncf.png)

<!--
-->
    
