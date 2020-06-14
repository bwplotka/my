@snap[north span-100]
![width=300](assets/images/GopherSpaceCommunity.png)

#### Optimizing Go for Clouds (and beyond @emoji[rocket])
#### _Practical Intro_
@snapend

@snap[south-east padded snap-100 text-04 text-italics text-right]
London, UK | 17.06.2020 | [London Gophers Meetup](https://www.meetup.com/LondonGophers/events/270419925/) | [Bartłomiej Płotka](https://bwplotka.dev) 
@snapend

Note:
Thanks .., hello everyone! I am super excited to be presenting today, in our local LondonGophers Meetup.
I was very often joining this meetup as a guest, so I am triple honoured now to share what I know about Go and Performance from practical
side. I am speaking from the virtual stage and I wish we could meet in reality, but let's focus on benefits: I am sure we have guest from outside of London,
I know about few Berlin friends, so there is always a bright side of things (: 

---
@snap[north span-95 text-center]
#### Optimizing Go for Clouds (and beyond @emoji[rocket])
#### _Practical Intro_
@snapend

@snap[south-east span-60 text-right padding]
![width=350](assets/images/GopherSpaceMentor.png)
@snapend

@snap[south span-50 fragment]
@tweet[https://twitter.com/bwplotka/status/1267029085013843971]
@snapend

Note:

Anyway, today we will be talking about writing performant Go code.  
in clouds but also in space!
 
---
@snap[north span-95 text-center]
#### Optimizing Go for Clouds (and beyond @emoji[rocket])
#### _Practical Intro_
@snapend

@snap[west span-75 text-07 padded]
@ol[list-fade-fragments](true)
1. In scale, do we even care about performant code? @note[Something]
1. How to approach and when to optimize things?
1. Data Driven Decisions: How to measure performance.
1. Optimization tricks & pitfalls
@olend
<br/><br/><br/>
@snapend

@snap[south-east span-60 text-right padding]
![width=350](assets/images/GopherSpaceMentor.png)
@snapend

Note:

https://www.meetup.com/LondonGophers/events/270419925/ (25m + 5mQ&A)
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

---?include=slides/common/whoami-go/PITCHME.md

---
@snap[north span-95 text-left]
#### Summary
@snapend

@snap[midpoint span-75 text-07 text-bold text-left]
@ol[](false)
* Amazing [ashleymcnamara gophers](https://github.com/ashleymcnamara/gophers)
@olend

---
@snap[north span-100]
## Thank You!
@snapend

@snap[west span-70 text-left text-06 padded]
@size[1.2em](**Feel free to ask questions @emoji[raising_hand]& discuss:**)
* _Live:_ on YouTube Stream
* _Offline:_ on [Gopher Slack `#london`](https://gophers.slack.com) 
  * My handle: `@bwplotka`
<br/><br/><br/><br/><br/><br/><br/><br/> 
@snapend

@snap[east span-40 text-05 text-center]
![width=200](assets/images/slides/qrcode-optimizing-go-code.png)
<br/><br/><br/><br/><br/>
@snapend

@snap[south span-96 text-center]
![width=800](assets/images/GoCommunity.png)
@snapend

---
@snap[north span-95 text-left]
#### Credits
@snapend

@snap[midpoint span-75 text-06 text-bold text-left]
@ol[](false)
* Amazing [ashleymcnamara gophers](https://github.com/ashleymcnamara/gophers)
@olend



