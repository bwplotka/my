@snap[north span-100]
![width=300](assets/images/slides/GopherSpaceCommunity.png)

#### Optimizing Go for Clouds (and beyond @emoji[rocket])
#### _Practical Intro_
@snapend

@snap[south-east padded snap-100 text-04 text-italics text-right]
London, UK | 17.06.2020 | [London Gophers Meetup](https://www.meetup.com/LondonGophers/events/270419925/) | [Bartłomiej Płotka](https://bwplotka.dev) 
@snapend

Note:
Thanks .., Hello everyone! I am super excited to be presenting today, in our local LondonGophers Meetup.
I was very often joining this meetup as a guest, so I am triple honoured now to share what I know about Go and Performance from practical
side. I am speaking from the virtual stage and I wish we could meet in reality, but let's focus on benefits of this situation:
For example I am sure we have guest from outside of London, I know about a few Berlin friends, so there is always a bright side of things (: 

---
@snap[north span-95 text-center]
#### Optimizing Go for Clouds (and beyond @emoji[rocket])
#### _Practical Intro_
@snapend

@snap[south-east span-60 text-right padding]
![width=350](assets/images/slides/GopherSpaceMentor.png)
@snapend

@snap[south span-50 fragment]
@tweet[https://twitter.com/bwplotka/status/1267029085013843971]
@snapend

Note:

Anyway, today we will be talking about writing performant Go code and optimizations overall.

This talk will be especially valid for the Go applications running for the Infrastructure, Cloud needs, so something from my area of
expertise. But, to be honest you can take this knowledge and apply to any Go Program, you know, CLI tools, GUI, or even SPACE!

(click) Because I don't know if you are aware you can use Go to automatically dock to International Space Station. How amazing is that?? 
 
---
@snap[north span-95 text-center]
#### Optimizing Go for Clouds (and beyond @emoji[rocket])
#### _Practical Intro_
@snapend

@snap[west span-75 text-07 padded]
###### Agenda:

@ol[list-fade-fragments list-spaced-bullets](true)
1. Does performance matter? _"Our design is scalable, machines big and code has to be readable, let's not worry about performance"_ @note[First of all, we will touch on the potential system misconception, so why performance for single application is still quite important nowadays and why you don't need to sacrifice readability!]
1. How to approach and when to optimize things? @note[Then we will discuss how to efficiently approach performance topic, how to start]
1. Data Driven Decisions: Measuring performance. @note[Particularly we will touch the critical part, which is how to make decisions regarding optimizations]
1. Optimization tricks & pitfalls @emoji[bomb] @note[Last but not the least I would love to share some tricks and usual patterns that helps improve things! But before that.. short introduction]
@olend
@snapend

@snap[south-east span-60 text-right]
![width=300](assets/images/slides/GopherSpaceMentor.png)
@snapend

Note:
Still Infrastructure mostly runs in Clouds not yet in Space, so let's get back to the Earth. We can divide our talk to 4 steps.

---?include=slides/common/whoami-go/PITCHME.md

---
@snap[north span-95 text-06 text-left padded]
##### Does performance matter?
@quote[ Let's not worry about performance here because...<br/><br/>](Your Tech Lead)
@snapend

@snap[north span-90 text-06 text-right padded fragment]
</br></br></br></br>
@css[text-yellow text-italics](...we are just guessing here, this is just an micro-optimization!)
@snapend

@snap[south-west span-95 padded fragment]
![width=300, shadow](assets/images/slides/premature_opt2.jpg)
@snapend

@snap[south-east span-95 padded fragment]
![width=300, shadow](assets/images/slides/premature_opt3.jpg)
<br/><br/>
@snapend

Note:

Awesome! Let's start.

---
@snap[north span-95 text-06 text-left padded]
##### Does performance matter?
@quote[ Let's not worry about performance here because...<br/><br/>](Your Tech Lead)
@snapend

@snap[north span-90 text-06 text-right padded]
</br></br></br></br>
@css[text-yellow text-italics](...we care about readability, let's not obfuscate our code!)
@snapend

@snap[south span-95 text-04 padded fragment]
@code[golang](slides/optimizing-go-for-clouds-go-meetup/perf.go)
@snapend

Note:

Awesome! Let's start.

---
@snap[north span-95 text-06 text-left padded]
##### Does performance matter?
@quote[ Let's not worry about performance here because...<br/><br/>](Your Tech Lead)
@snapend

@snap[north span-90 text-06 text-right padded fragment]
</br></br></br></br>
@css[text-yellow text-italics](...our machines have [224 CPU cores and 24 TBs of RAM](https://aws.amazon.com/ec2/instance-types/high-memory/))
@snapend

@snap[south span-95 padded fragment]
![width=400, shadow](assets/images/slides/brute-force.jpeg)
@snapend

Note:

Awesome! Let's start.

---
@snap[north span-95 text-05 text-left padded]
##### Does performance matter?
@quote[Let's not worry about performance here because...](Your Tech Lead)
@snapend

@snap[midpoint span-95 text-05 text-right padding]
@ul[list-spaced-bullets list-fade-fragments](true)
* ...we are just guessing here, this might be "micro-optimzation".
* ...we care about readability, let's not obfuscate our code.
* ...our machines have [224 CPU cores and 24 TBs of RAM](https://aws.amazon.com/ec2/instance-types/high-memory/).
* ...our system scales horizontally. 
@ulend
<br/>
@snapend

Note:

Awesome! Let's start.

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
![width=800](assets/images/slides/GoCommunity.png)
@snapend

---
@snap[north span-95 text-left]
#### Credits
@snapend

@snap[midpoint span-75 text-06 text-bold text-left]
@ol[](false)
* Amazing [ashleymcnamara gophers](https://github.com/ashleymcnamara/gophers)
@olend

----

Note: 

Backup: 
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

