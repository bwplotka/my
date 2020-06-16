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
![width=300](assets/images/slides/GopherSpaceMentor.png)
@snapend

@snap[south span-50 fragment]
@tweet[https://twitter.com/bwplotka/status/1267029085013843971]
@snapend

Note:

Anyway, today we will be talking about writing performant Go code and optimizations overall.

This talk will be especially valid for the Go applications running for the Infrastructure, Cloud needs, so something from my area of
expertise. But, to be honest you can take this knowledge and apply to any Go Program, you know, CLI tools, GUI, or even SPACE!

[C] Because I don't know if you are aware you can use Go to automatically dock to International Space Station. How amazing is that?? 
 
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
1. Go optimization tricks & pitfalls @emoji[bomb] @note[Last but not the least I would love to share some tricks and usual patterns that helps improve things! But before that.. short introduction]
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
@quote[ We don't need to optimize this program because...<br/><br/>](Your Code Reviewer)
@snapend

@snap[north span-90 text-06 text-right padded fragment]
</br></br></br></br>
@css[text-yellow text-italics](...we are just guessing here, this is just a micro-optimization!)
@snapend

@snap[south-west span-95 padded fragment]
![width=300, shadow](assets/images/slides/premature_opt2.jpg)
@snapend

@snap[south-east span-95 padded fragment]
![width=400, shadow](assets/images/slides/premature_opt3.jpg)
<br/>
@snapend

@snap[north span-95 text-07 text-black text-bold padded fragment]
<br/><br/><br/><br/><br/>
@box[bg-gold rounded](Sure, but there are some basic Go patterns to use, and pitfalls to avoid from the start of the project!)
@snapend

Note:

Awesome! Let's start. Let's imagine we are adding some feature or improvement in the code, and in the PR we have following 
review: ...

[C] And this might be good advice, there is quite a battle in SW development about microoptimizations might be premature optimizations.
This means that potentially we would be adding unnecessary complexity to the code that might not needed. It might be
that it's just not on critical path, so the optimization really does not give much.

[C] So overall in many cases the YAGNI rule kicks in, meaning that we simply might be wasting our time here. 

So from YAGNI code practice, does performance matter? 
I would say yes, while premature optimizations are evil there are some basic Go patterns you can stick to, in order to avoid basic performance pitfalls

---
@snap[north span-95 text-06 text-left padded]
##### Does performance matter?
@quote[ We don't need to optimize this program because...<br/><br/>](Your Code Reviewer)
@snapend

@snap[north span-95 text-06 text-right padded]
</br></br></br></br>
@css[text-yellow text-italics](...we mainly care about readability, let's not obfuscate our code!)
@snapend

@snap[south span-100 text-04 padded fragment]
@code[golang code-noblend code-max zoom-05](slides/optimizing-go-for-clouds-go-meetup/perf.go?lines=31-51,58-60)
_[Snippet from latest Thanos code for lookup of label names in memory-maped file](https://github.com/thanos-io/thanos/blob/63ef382fc335969fa2fb3e9c9025eb0511fbc3af/pkg/block/indexheader/binary_reader.go#L841)_ 
@snapend

@snap[south-east span-95 padded fragment]
![width=400, shadow](assets/images/slides/readable.jpg)
<br/><br/><br/>
@snapend

@[22-24, zoom-20]

@snap[north span-95 text-07 text-black text-bold padded fragment]
<br/><br/><br/><br/><br/>
@box[bg-gold rounded](Fair, but with good balance and consistency, code can be still readable)
@snapend

Note:

Let's focus on yet another potential misconception here. (...) And there is lots of truth here!

[C] Let's consider this snippet of the code from Thanos project. Thanos is kind of horizontally scalable metric databases
based on Prometheus and this code is for fetching certain data from file that is memory-mapped on Linux based systems.

[C] We can definitely agree it's some sophisticated code which might be not clear immediately when you look on it. 

[C] Especially if you look on my favorite line here, function yoloString, would you accept this in your production code?

It's overall a very fair point, we chose Go because it's simple, consistent and readable. That's why it is so efficient to write programs in Go.
So.. does performance really matter if it reduces readability?

I would again advocate yes - performance still matter as there are ways to have performant and still readable Go code. Especially if we 
consider certain performance patterns, maybe even yoloString, a consistent pattern in our code, it's not longer surprising, thus it
still might be considered readable.

---
@snap[north span-95 text-06 text-left padded]
##### Does performance matter?
@quote[ We don't need to optimize this program because...<br/><br/>](Your Code Reviewer)
@snapend

@snap[north span-90 text-06 text-right padded]
</br></br></br></br>
@css[text-yellow text-italics](...our machines have [224 CPU cores and 24 TBs of RAM](https://aws.amazon.com/ec2/instance-types/high-memory/))
@snapend

@snap[south-west span-95 padded fragment]
![width=400, shadow](assets/images/slides/aws-machines.png)
<br/>
@snapend

@snap[south-east span-95 padded fragment]
![width=400, shadow](assets/images/slides/brute-force.jpeg)
<br/><br/>
@snapend

@snap[north span-95 text-07 text-black text-bold padded fragment]
<br/><br/><br/><br/><br/>
@box[bg-gold rounded](Still there are limitations: Slow garbage collections for huge heaps and multicore architecture fun: IO, network, memory bandwidth etc)
@snapend

Note:

Some times we have cases that we just have computing power needed, so why we should focus on performance. And that's a solid
statement as well. 

[C] For example AWS has those epic, huge bare metal servers available for you, and there are companies happy 
to pay for those.

[C] And that gives this impression that we don't need to focus on code performance much, we can just do whatever, it should not matter.

Well, in practice it's not that nice as it looks. Concurrent programming is hard, despite Go having pretty amazing framework for it
like go routines and channels, you will hit process scalability limitation pretty quickly. Think about cases like resource starvation or 
garbage collection latency on an enormous heap so shared memory across go routines. Not mentioning other aspects like memory or disk IO bandwidth. 
At the end you have to optimize code in some way or scale out of the single process.

---
@snap[north span-95 text-06 text-left padded]
##### Does performance matter?
@quote[ We don't need to optimize this program because...<br/><br/>](Your Code Reviewer)
@snapend

@snap[north span-90 text-06 text-right padded]
</br></br></br></br>
@css[text-yellow text-italics](...there is no need, our system scales horizontally )🤷
@snapend

@snap[south-west span-95 padded fragment]
![width=400, shadow](assets/images/slides/twitterdesign.png)
@snapend

@snap[south-east span-50 padded fragment]
![width=450, shadow](assets/images/slides/whatsapp.png)
<br/>
<br/>
@snapend

@snap[midpoint span-95 padded fragment]
![width=400, shadow](assets/images/slides/googledocs.png)
@snapend

Note:

Which brings us to last reason why you would potentially ignore code optimizations. Our code have unlimited horizontal
scalability, why would we care how much single process use?

This is actually something I see a lot in the infrastructure culture.

Nowadays you want to be a backend engineer on top typical programming and linux questions on interview, you have to show your skills in
designing scalable systems. [C] You have to either design system like Twitter or Messenger or like Google Docs, you need to go through
different phases, and explain how it will scale from 100 users to 10 thousands to millions.

---
@snap[north span-95 text-06 text-left padded]
##### Does performance matter?
@quote[ We don't need to optimize this program because...<br/><br/>](Your Code Reviewer)
@snapend

@snap[north span-90 text-06 text-right padded]
</br></br></br></br>
@css[text-yellow text-italics](...there is no need, our system scales horizontally )🤷
@snapend


@snap[south-west span-95 text-08 padded fragment]
![width=400, shadow](assets/images/slides/scaleup.gif)
Vertical Scalability
@snapend

@snap[south-east span-95 text-08 padded fragment]
![width=400, shadow](assets/images/slides/scaleout.gif)
Horizontal Scalability
@snapend

@snap[north span-95 text-07 text-black text-bold padded fragment]
<br/><br/><br/><br/><br/>
@box[bg-gold rounded](Performance still matters. Think: complexity of distributed applications, cost, cold start, etc...)
@snapend

Note:

The key concept that every cloud engineer has to know then is Scalability of the system. It's extremely exciting topic and it essentially
means how to grow or shrink you backend or service capabilities with the request traffic. So when your application become too slow or require 
more CPU, Memory than you have available to serve your users... what do you do?

[C] Basic way of doing this is through something called scale up/down procedure, in different words Vertical scalability. You 
increase capabilities of your service by just giving it more resources, more CPU, RAM, better network, but usually it's just single process, single machine

[C] Now this become very boring recently, and for last 5y the new fashion was to scale out / scale in method. Which means that you can grow your application
by just replicating it horizontally on different machines. In this model someone can say that optimizing single process is not a priority, because
you can just add another server or virtual machine or container etc.

[C] The problem is that as you seen horizontal scalability became a buzz word, certain "fashion". And this is actually the true motivation for me for making 
this presentation. This scale out fashion, because maybe more exciting for engineers caused many people to really sometimes **prematurely** dive into distributing
their application and using tools like Kubernetes or Mesos, even though they can quickly optimize a couple of critical paths and unnecessary allocation in their code and allow
single-process Go application to serve thousands of users without issues.    

So I want to reiterate, performance still matters. Horizontal scaling can be extremely expensive and difficult to implement properly. Not mentioning overhead and delay in scaling this way, especially
if the Go code is not optimized.

---
@snap[north span-95 text-05 text-left padded]
##### How to approach and when to optimize Go code?
@snapend


Note:

Overall, we can see that there are always excuses to avoid peformance optimization. At the end it comes to the same conclusion, 

---
@snap[north span-95 text-05 text-left padded]
##### Data Driven Decisions: Measuring performance.
@snapend


Note:

---
@snap[north span-95 text-05 text-left padded]
##### Optimization tricks & pitfalls @emoji[bomb]
@snapend


Note:


---
@snap[north span-95 text-05 text-left padded]
##### Summary
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

