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
1. Should you optimize your code for performance? _"Our design is scalable, machines big and code has to be readable, let's not worry about performance"_ @note[First of all, we will touch on the potential misconception, so essentially why performance for single application is still quite important nowadays and why you don't need to sacrifice readability!]
1. How to approach performance optimizations in Go? @note[Then we will discuss how to efficiently approach performance, how to start with optimizing and when]
1. Go optimization tricks & pitfalls @emoji[bomb] @note[Last but not the least I would love to share some tricks and usual patterns that helps improve things! But before that.. short introduction]
@olend
@snapend

@snap[south-east span-60 text-right]
![width=300](assets/images/slides/GopherSpaceMentor.png)
@snapend

Note:
Still Infrastructure mostly runs in Clouds not yet in Space, so let's get back to the Earth. We can divide our talk to 3 steps.

---?include=slides/common/whoami-go/PITCHME.md

---
@snap[north span-95 text-06 text-left padded]
##### Code Optimization
@snapend

@snap[east span-95 padded]
![width=200](assets/images/slides/SPACEGIRL1.png)
<br/><br/><br/><br/><br/><br/><br/><br/>
@snapend

@snap[midpoint span-95 text-06 text-left padded]
@quote[Code optimization is any method of code modification to improve code quality and efficiency. A program may be optimized so that it becomes a smaller size, consumes less memory, executes more rapidly, or performs fewer input/output operations.]()
@snapend

@snap[south span-95 text-05 text-left padded fragment]
(Soft) Requirement: 
_An optimized program must have the same output and side effects as its non-optimized version._
<br/><br/><br/><br/>
@snapend

Note:

Let's start our optimization journey with definition!

a code optimization is essentially a method of changing the code in a way to improve something. Maybe smaller binary size, maybe
to make program faster or use less memory.

There is actually on soft requirement: is that an optimized program must have the same output and
side effects as its non-optimized version. This requirement, however, is soft. As it may be ignored,
in the case that the benefit from optimization is estimated to be more important than keeping the same output!

---
@snap[north span-95 text-06 text-left padded]
##### Should you optimize your code for performance?
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

Note:

Awesome! Let's start. Let's imagine we are adding some feature or improvement in the code, and in the PR we have following 
review: ...

[C] And this might be good advice, there is quite a battle in SW development about microoptimizations that might be premature.
This means that potentially we would be adding unnecessary complexity and cluttering our code that might not needed. 
* It might be that the optimization is done not on critical path, so the optimization really does not give much.
* Or maybe optimization is just not needed overall, so we might want to spent time on something else instead.

[C] So overall in many cases the YAGNI rule kicks in so "You are not gonna need", meaning that we simply might be wasting our time by
adding extra complexity.

So from YAGNI code practice, does performance matter? 

---
@snap[north span-95 text-06 text-left padded]
##### Should you optimize your code for performance?
@quote[ We don't need to optimize this program because...<br/><br/>](Your Code Reviewer)
@snapend

@snap[north span-90 text-06 text-right padded]
</br></br></br></br>
@css[text-yellow text-italics](...we are just guessing here, this is just a micro-optimization!)
@snapend

@snap[south-west span-95 padded]
![width=300, shadow opacity-50](assets/images/slides/premature_opt2.jpg)
@snapend

@snap[south-east span-95 padded]
![width=400, shadow opacity-50](assets/images/slides/premature_opt3.jpg)
<br/>
@snapend

@snap[midpoint span-95 text-07 text-black text-bold padded]
<br/><br/><br/><br/><br/>
@box[bg-gold rounded](True! But there are some basic Go patterns to use, and pitfalls to avoid from the start of the project!)
@snapend

Note:

I would say yes, while premature optimizations are evil there are some basic Go patterns you can stick to, in order to avoid basic performance pitfalls
I hopefully can list some of the tricks near the finish of this presentation.

---
@snap[north span-95 text-06 text-left padded]
##### Should you optimize your code for performance?
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

Note:

Let's focus on yet another potential misconception here. (..readdbility) 
And there is lots of truth here!

[C] Let's consider following snippet of the code from Thanos project. Thanos is kind of horizontally scalable metric database
based on Prometheus and this code is for fetching certain data from file that is memory-mapped on Linux based systems. 
So as you can imagine, very critical path of project.

[C] We can definitely agree that this sophisticated piece of code might be not clear immediately from start, when you look on it. 

Especially if you look on my favorite line here,[C]  function yoloString, It's actually pretty neat, it allows to convert through different types without
extra allocation, reusing the same memory space. In this example, between bytes and strings. BUT would you accept this in your production code?

At then end it's overall a very fair point, to avoid extreme optimization to keep code readable. 
After all we chose Go because it's simple, consistent and readable. That's why it is so efficient to write programs in Go.
So.. does performance really matter if it reduces readability?

---
@snap[north span-95 text-06 text-left padded]
##### Should you optimize your code for performance?
@quote[ We don't need to optimize this program because...<br/><br/>](Your Code Reviewer)
@snapend

@snap[north span-95 text-06 text-right padded]
</br></br></br></br>
@css[text-yellow text-italics](...we mainly care about readability, let's not obfuscate our code!)
@snapend

@snap[south span-100 text-04 padded opacity-50]
@code[golang code-noblend code-max zoom-05](slides/optimizing-go-for-clouds-go-meetup/perf.go?lines=31-51,58-60)
_[Snippet from latest Thanos code for lookup of label names in memory-maped file](https://github.com/thanos-io/thanos/blob/63ef382fc335969fa2fb3e9c9025eb0511fbc3af/pkg/block/indexheader/binary_reader.go#L841)_ 
@snapend

@snap[south-east span-95 padded]
![width=400, shadow opacity-50](assets/images/slides/readable.jpg)
<br/><br/><br/>
@snapend

@snap[midpoint span-95 text-07 text-black text-bold padded]
<br/><br/><br/><br/><br/>
@box[bg-gold rounded](Fair, but with good balance and consistency, code can be still readable)
@snapend

Note:

I would again advocate yes - performance still matter as there are ways to have performant and still readable Go code. Especially if we 
consider certain performance patterns, to be used consistently across the code, maybe even yoloString, so it's not longer surprising.

---
@snap[north span-95 text-06 text-left padded]
##### Should you optimize your code for performance?
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

Note:

Other excuse, we hear the comment that we just have all the computing power needed, so why we should focus on performance. And that's a solid
statement in some cases. 

[C] For example AWS has those epic, huge bare metal servers available for you, and there are companies happy 
to pay for those.

[C] And that gives this impression that we don't need to focus on code performance much, we can just do whatever, it should not matter.
---
@snap[north span-95 text-06 text-left padded]
##### Should you optimize your code for performance?
@quote[ We don't need to optimize this program because...<br/><br/>](Your Code Reviewer)
@snapend

@snap[north span-90 text-06 text-right padded]
</br></br></br></br>
@css[text-yellow text-italics](...our machines have [224 CPU cores and 24 TBs of RAM](https://aws.amazon.com/ec2/instance-types/high-memory/))
@snapend

@snap[south-west span-95 padded opacity-50]
![width=400, shadow](assets/images/slides/aws-machines.png)
<br/>
@snapend

@snap[south-east span-95 padded opacity-50]
![width=400, shadow](assets/images/slides/brute-force.jpeg)
<br/><br/>
@snapend

@snap[midpoint span-95 text-07 text-black text-bold padded]
<br/><br/><br/><br/><br/>
@box[bg-gold rounded](Still there are limitations: Slow garbage collections for huge heaps and multicore architecture fun: IO, network, memory bandwidth etc)
@snapend

Note:

Well, in practice it's not that nice as it looks. Concurrent programming is hard, despite Go having pretty amazing framework for it.

With lots of go routines and channels, you will hit process scalability limitation at some point. Think about cases like resource starvation or 
garbage collection latency on an enormous heap so shared memory across go routines. 

Not mentioning other aspects like memory or disk IO bandwidth. 

At the end you have to optimize the code in some way or scale out of the single process.

---
@snap[north span-95 text-06 text-left padded]
##### Should you optimize your code for performance?
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

Which brings us to last misconception, why someone would potentially ignore doing optimizations. We often here that our
code have unlimited horizontal scalability, why would we care how much single process uses?

This is actually something I see a lot in the infrastructure culture.

And nowadays if you want to be hired as a backend engineer, on the top typical programming and linux questions on interview, you have to show your skills in
designing scalable systems 

[C] You have to either design system like Twitter or Messenger or like Google Docs, you need to go through
different phases, and explain how it will scale from 100 users to 10 thousands and then up to million.

At the end the key concept that every cloud engineer has to know then is Scalability of the system. It's extremely exciting topic and it essentially
means how to grow or shrink you backend or service capabilities with the request traffic. So when your application become too slow or require 
more CPU, Memory than you have available ... what do you do?

---
@snap[north span-95 text-06 text-left padded]
##### Should you optimize your code for performance?
@quote[ We don't need to optimize this program because...<br/><br/>](Your Code Reviewer)
@snapend

@snap[north span-90 text-06 text-right padded]
</br></br></br></br>
@css[text-yellow text-italics](...there is no need, our system scales horizontally )🤷
@snapend

@snap[south-west span-95 text-08 padded]
![width=400, shadow](assets/images/slides/scaleup.gif)
Vertical Scalability
@snapend

Note:

[C] Basic way of doing this is through something called scale up/down procedure, in different words Vertical scalability. You 
increase capabilities of your service by just giving it more resources, more CPU, RAM, better network, but usually it's just single process, single machine

Now this become very boring recently, and for last 5y the new fashion emerged...

---
@snap[north span-95 text-06 text-left padded]
##### Should you optimize your code for performance?
@quote[ We don't need to optimize this program because...<br/><br/>](Your Code Reviewer)
@snapend

@snap[north span-90 text-06 text-right padded]
</br></br></br></br>
@css[text-yellow text-italics](...there is no need, our system scales horizontally )🤷
@snapend

@snap[south-west span-95 text-08 padded opacity-50]
![width=400, shadow](assets/images/slides/scaleup.gif)
Vertical Scalability
@snapend

@snap[south-east span-95 text-08 padded]
![width=400, shadow](assets/images/slides/scaleout.gif)
Horizontal Scalability
@snapend

Note:

Scale out / scale in method. Which means that you can grow your application
by just replicating it horizontally on different machines. 

And particularly in this model someone can say that optimizing single process is not a priority, because
you can just add another server or virtual machine or container etc.

The problem is that as you seen horizontal scalability became a buzz word, certain "fashion". And this problem, misconception
is actually the true motivation for me for making this presentation. 

Because scale-out fashion, is maybe more exciting for engineers? caused many people to really sometimes **prematurely** dive into distributing
their application and using tools like Kubernetes or Mesos. 
 
And that's despite the fact that they can quickly optimize a couple of critical paths, unnecessary allocation in their code and allow single-process Go application 
to serve thousands of users without issues.    

---
@snap[north span-95 text-06 text-left padded]
##### Should you optimize your code for performance?
@quote[ We don't need to optimize this program because...<br/><br/>](Your Code Reviewer)
@snapend

@snap[north span-90 text-06 text-right padded]
</br></br></br></br>
@css[text-yellow text-italics](...there is no need, our system scales horizontally )🤷
@snapend

@snap[south-west span-95 text-08 padded opacity-50]
![width=400, shadow](assets/images/slides/scaleup.gif)
Vertical Scalability
@snapend

@snap[south-east span-95 text-08 padded opacity-50]
![width=400, shadow](assets/images/slides/scaleout.gif)
Horizontal Scalability
@snapend

@snap[midpoint span-95 text-07 text-black text-bold padded]
<br/><br/><br/><br/><br/>
@box[bg-gold rounded](Performance still matters. Think: complexity of distributed applications, cost, cold start, etc...)
@snapend

Note:

So I want to reiterate, performance still matters. Horizontal scaling can be extremely expensive and difficult to implement properly.
Not mentioning overhead and delay in scaling this way, especially if the Go code is not optimized.

---
@snap[north span-95 text-05 text-left padded]
##### How to approach performance optimizations?
@snapend

@snap[south-west span-95 padded]
![width=150](assets/images/slides/SPACEGIRL_GOPHER.png)
@snapend

@snap[north span-90 text-8 text-bold padded fragment]
<br/>
@box[rounded](Step 1: Define the problem; find the bottleneck.)
@snapend

@snap[midpoint span-90 text-08 padded fragment]
@quote[<br/>1. First rule of Optimization: Don't do it.<br/>2. Second rule of Optimization: Don't do it... yet.<br/>3. Profile before Optimizing](http://wiki.c2.com/?RulesOfOptimization)
@snapend

Note:

Overall, we can see that there are always excuses to avoid performance optimization. At the end it comes to the same conclusion,
performance matters, but it has it consequences. Mainly that it's hard to achieve, takes time and might impact readability.

So, how to approach this topic? 

[C] First and foremost: Step number one! Detect the bottleneck, find the problem you want to solve.  

[C] There is a good rule related to premature optimization as touched before: Don't do any peformance changes if they are not needed
now or in near future actually

There are probably more important things you can spend your time on. 

---
@snap[north span-95 text-05 text-left padded]
##### How to approach performance optimizations?
@snapend

@snap[south-west span-95 padded]
![width=150](assets/images/slides/SPACEGIRL_GOPHER.png)
@snapend

@snap[north span-90 text-8 text-bold padded]
<br/>
@box[rounded](Problem: API / RPC / Command / Action execution is...)
@snapend

@snap[west span-45 text-06 padded fragment]
a) @emoji[watch] very slow or time-outs.
<br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>
@snapend

@snap[east span-45 text-06 text-center padded fragment]
b) @emoji[fire] crashing the machine or process is just killed before succeeding.
<br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>
@snapend

@snap[south-west span-45 text-05 padded fragment]
![width=400, shadow](assets/images/slides/compressible.gif)
e.g CPU time, Disk IO, Memory IO, Network IO 
@snapend

Note:

This sounds solid, but how to do that? Well, usually you don't find the problem, the problem finds you!!

Generally things you can potentially solve by optimizing your Go code can be divided into two groups: 

[C] [C] (...)

What's the difference? Well both symptoms are actually because of the same reason: host that process is running on does not have enough resources to
perform the operation. The difference between these two is actually in the characteristics of the underlying resource that is saturated (not enough of it).

[C] First one is compressible resources like.. Those the resources you can throttle temporarily without stopping the program. This usually means freezing execution
or slowing it down.

---
@snap[north span-95 text-05 text-left padded]
##### How to approach performance optimizations?
@snapend

@snap[south-west span-95 padded]
![width=150](assets/images/slides/SPACEGIRL_GOPHER.png)
@snapend

@snap[north span-90 text-8 text-bold padded]
<br/>
@box[rounded](Problem: API / RPC / Command / Action execution is...)
@snapend

@snap[west span-45 text-06 padded]
a) @emoji[watch] very slow or time-outs.
<br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>
@snapend

@snap[east span-45 text-06 text-center padded]
b) @emoji[fire] crashing the machine or process is just killed before succeeding.
<br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>
@snapend

@snap[south-west span-45 text-05 padded opacity-50]
![width=400, shadow](assets/images/slides/compressible.gif)
e.g CPU time, Disk IO, Memory IO, Network IO 
@snapend

@snap[south-east span-45 text-05 padded]
![width=400, shadow](assets/images/slides/incompressible.gif)
e.g Storage: Memory, Disk, or DB Space, Power
@snapend

Note:

[C] Second are incompressible resources Those you cannot throttle without causing a failure. For example if process requires more memory and there is none, 
Linux kernel has to kill such offending process as nothing better can be really done. 

It terminates that process which is popularly known as OOM or out of memory exception.

This is quite important differentiations and will help you to tell what kind of bottleneck you should solve first while optimizing Go program.

---
@snap[north span-95 text-05 text-left padded]
##### How to approach performance optimizations?
@snapend

@snap[south-west span-95 padded]
![width=150](assets/images/slides/SPACEGIRL_GOPHER.png)
@snapend

@snap[north span-90 text-8 text-bold padded]
<br/>
@box[rounded](Bottleneck: What part of the code causes undesired resource consumption?)
@snapend

@snap[west span-90 text-06 padded fragment]
a) @emoji[watch] Execution is very slow or time-outs.
<br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>
@snapend

@snap[south span-95 text-04 padded bg-go fragment]
![width=600, shadow](assets/images/slides/querylatency.png)
Symptom: Alert (e.g via [Alertmanager](https://prometheus.io/docs/alerting/latest/alertmanager/))
<br/><br/><br/><br/><br/><br/><br/><br/><br/>
@snapend

@snap[south span-95 text-04 padded bg-go fragment]
![width=600, shadow](assets/images/slides/duration.png)
Drill down 1: Metrics via [Prometheus](https://prometheus.io) and [Grafana](https://grafana.com/) dashboards. 
<br/><br/><br/><br/><br/>
@snapend

@snap[south span-95 text-04 padded bg-go fragment]
<br/><br/><br/><br/>
![width=800, shadow](assets/images/slides/Trace.png)
Drill down 2: Traces via [Jaeger](https://www.jaegertracing.io/). 
<br/><br/><br/><br/><br/>
@snapend

@snap[south span-95 text-04 padded bg-go fragment]
![width=800, shadow](assets/images/slides/flame.png)
Drill down 3a: Profiling via [pprof](https://jvns.ca/blog/2017/09/24/profiling-go-with-pprof/) [Flamegraph](http://www.brendangregg.com/flamegraphs.html) 
<br/><br/><br/>
@snapend

@snap[south span-95 text-04 padded bg-go fragment]
![width=600, shadow](assets/images/slides/profile1.png)
Drill down 3b: Profiling via [pprof](https://jvns.ca/blog/2017/09/24/profiling-go-with-pprof/)
@snapend

Note:

Ok, so we know what is our problem, but how to tell what's exactly piece of code causes the problem, was is the root cause from given 
symptom!

And quick clue: All that's help doing it is fitting the term "OBSERVABILITY"

[C] And let's focus on slow execution problem first.

[C] Usually journey of backend engineer starts with an alert! This is usually a first symptom that you can - a notification that some
process is slower than usual.

[C] Then we can navigate to Grafana and drill down to certain component using metric signal

[C] When we know roughly the component we can usually using Tracing thanks to Jaeger - to detect some slow request, and check 
exactly what were the timing of each phases,

[C] And at then we hopefully can get some profiles of the program running itself, to check what exactly line of code is taking so much
CPU cycles. I am not going to dive super deeply into profiling on my presentation there are links to good blog post about it, in this flamegraphs!
 
And at the end for we could see in our example thanks to different CPU profile view: Graph! 

...We spend lots of cycles on TextMarshaller and this is where we should focus our optimization on...

---
@snap[north span-95 text-05 text-left padded]
##### How to approach performance optimizations?
@snapend

@snap[south-west span-95 padded]
![width=150](assets/images/slides/SPACEGIRL_GOPHER.png)
@snapend

@snap[north span-90 text-8 text-bold padded]
<br/>
@box[rounded](Bottleneck: What part of the code causes undesired resource consumption?)
@snapend

@snap[west span-90 text-06 padded]
b) @emoji[fire] Execution is crashing the machine or process is just killed before succeeding.
<br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>
@snapend

@snap[south span-95 text-04 padded bg-go fragment]
![width=900, shadow](assets/images/slides/crashloop.png)
Symptom: Process is crashing e.g on [Kubernetes](http://kubernetes.io/) (via [OpenShift Console](https://www.redhat.com/en/technologies/cloud-computing/openshift/try-it?sc_cid=7013a000002DkSqAAK&gclid=CjwKCAjw_qb3BRAVEiwAvwq6VtRhQegkDHNqedqfhFpGxGhhTxf3PJ4gTrlt5R9baahwYrAu5qgWyRoC_FcQAvD_BwE&gclsrc=aw.ds))
<br/><br/><br/><br/><br/><br/><br/><br/><br/>
@snapend

@snap[south span-95 text-04 padded bg-go fragment]
![width=700, shadow](assets/images/slides/memory.png)
Drill down 1: Metrics via [Prometheus](https://prometheus.io) and [Grafana](https://grafana.com/) dashboards. 
@snapend

@snap[south span-95 text-04 padded bg-go fragment]
<br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>
Drill down 2: Traces? @css[text-pink](Not really useful, it's not latency issue...)
<br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>
@snapend

@snap[south span-95 text-04 padded bg-go fragment]
<br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>
Drill down 2: Profiling? @css[text-pink](Profiling what, process already crashed...)
<br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>
@snapend

@snap[south span-95 text-04 padded bg-go fragment]
![width=500, shadow](assets/images/slides/conprof.png)
Drill down 2: Continous profiling! via [ConProf](https://github.com/conprof/conprof) (check good intro [here](https://youtu.be/kRVE15j1zxQ?t=221))
@snapend

Note:

However for potentially crashing service, so saturation of incompressible resources, it's not that easy! 

[C] Our symptom is now different: For example in case of Kubernetes, we would see CRASH LOOP

[C] If we try to see Grafana, and memory usage, we can see it immidiately after crash, gets up and tries to use too much, gets OOM.

[C] Now if we would follow previous example, we could try tracing. But this is not that easy, as this not latency issue, and potentially
not a single request, or go routine causing this. Rather all things together. 

[C] so maybe we can try profiling? Nope. Well process is constantly crashing, immediately after start, so it's somehow really hard to get profiles in right moment.

As you can see it's not easy... but there are some ways, something you can try is..
 
[C] Continous profiling! So here we are using ConProf which is open source, maintained by us as well, and I am not going to details again but TL;DR is allows to catch
profiles every 15 seconds, so you can see the profiles retroactively, allowing us to figure out the code lines, or libraries that causing huge or many allocations.

So overall, as you can see, even detecting, and drilling down to actually root cause can take time and effort. 

---
@snap[north span-95 text-05 text-left padded]
##### How to approach performance optimizations?
@snapend

@snap[south-west span-95 padded]
![width=150](assets/images/slides/SPACEGIRL_GOPHER.png)
@snapend

@snap[north span-100 text-8 text-bold padded]
<br/>
@box[rounded](Step 2: Find the right balance, a _tradeoff_.<br/> What's more important?)
@snapend

@snap[west span-45 text-06 padded]
@box[rounded bg-gold box-padded](CPU)
@snapend

@snap[midpoint span-45 text-10 padded]
<br/><br/><br/><br/><br/>
🤔
?
@snapend

@snap[east span-45 text-06 padded]
@box[rounded bg-purple box-padded](Memory)
@snapend

@snap[west span-45 text-06 padded]
<br/><br/><br/><br/><br/><br/>
@box[rounded bg-green box-padded](Disk)
@snapend

@snap[east span-45 text-06 padded]
<br/><br/><br/><br/><br/><br/>
@box[rounded bg-blue box-padded](Network)
@snapend

@snap[south-west span-45 text-06 padded]
@box[rounded bg-gray box-padded](Functionality)
<br/><br/><br/><br/><br/>
@snapend

@snap[south-east span-45 text-06 padded]
@box[rounded bg-pink box-padded](Readability)
<br/><br/><br/><br/><br/>
@snapend

Note:

So once we figured out problem, next is Step number two: To decide where you want to be?
 
Often when optimizing you have to sacrifice one resource to solve saturation of others.

Generally all optimizations, both micro and big system level optimizations really jumps from one resource to another depending on the bottleneck.

For example you want to have your program to be faster knowing the saturation of the CPU time is your bottleneck?
 
1. For example searching through documents in the storage, you can lean more on disk and memory and precompute index and caches. This way search operation will
need much less CPU cycles, thus it can be potentially much much faster.

2. On the other hand, if your program crashes because of not enoguh memory, you might want to optimize your program to use more CPU instead, 
by implementing some kind of streaming and increase your programs concurrency. 

3. Last but not the least you maybe want to limit some functionality or change it, to improve readability and disk usage.

So. It's very important that RARELY you can optimize code without sacrificing something else. This is called a tradeoff. 
The key is to choose based on your priority.

---
@snap[north span-95 text-05 text-left padded]
##### How to approach performance optimizations?
@snapend

@snap[north span-100 text-8 text-bold padded]
<br/>
@box[rounded](Step 3. Optimize & Measure: Data Driven Decisions.)
@snapend

@snap[midpoint span-100 text-06 padded fragment]
![width=800](assets/images/slides/Measurement.png)
<br/>
@snapend

@snap[south span-95 text-06 padded]
@ol[list-spaced-bullets text-08](true)
1. Benchmarks (aka "micro-benchmarks"): [go test -bench](https://dave.cheney.net/2013/06/30/how-to-write-benchmarks-in-go), [benchcmp old new](https://godoc.org/golang.org/x/tools/cmd/benchcmp), [benchstat](https://godoc.org/golang.org/x/perf/cmd/benchstat), [funcbench](https://github.com/prometheus/test-infra/tree/master/funcbench)
1. Load Tests (Deploy & Measure): [prombench](https://github.com/prometheus/test-infra/tree/master/prombench), Kubernetes + Prometheus, [perf](http://www.brendangregg.com/perf.html)
@olend
<br/><br/>
@snapend

Note:

So finally! Out  problem is defined, exact bottleneck found the we agreed on direction of our optimization. N

Now we can start actually coding! But just before that, to perform optimizations effectively we need to learn how to measure the results of our work first.
High level flow would look like this [C] 

First you have to inital benchmark. Something that we will take as a baseline for future comparision.

And there are two good ways of doing it:
[C] Microbenchmarks, usually done by `go test` really, there are good blog post about those and amazing tools.
[C] Then we can also try to deploy and just measure using maybe metrics. And there automation for Go as well!

So what happens is very iterative model. You benchmark first, then if you are happy, try to deploy and check. 
On the first run, you have initial results, so then you can start optimizing. Then you have to measure it in some way,
either by microbenchmarks or full load test. In any step, if you are not satisfied, you do it again and again.

Only when you are totally happy, you can release it!

This is very very important. Essentially. Don't trust your instincts here. Always make sure you measure the result.
This is very tedious sometimes, but every programming language especially Go holds thousands of compiler optimizations, and operating
systems, kernels are having even more and they are changing constantly. So make sure you avoid suprisies and improve code step by step 
with checks and this is called Data Driven Decision Methodology.

---
@snap[north span-95 text-05 text-left padded]
##### Few optimization tricks & pitfalls @emoji[bomb]
@snapend

Note:

That was theory! Now for last 5 minutes, let's jump into a few optimization tricks you can apply generally.

---
@snap[north span-95 text-05 text-left padded]
##### Few optimization tricks & pitfalls @emoji[bomb]
@snapend

@snap[south-east span-100 text-06 text-gray]
This is leaking memory in net/http package.                        
@snapend

@code[golang code-noblend code-max zoom-10](slides/optimizing-go-for-clouds-go-meetup/leak.go?lines=12-23)

@[6,7-8,10-11]

Note:

First one is related to the standard net/http package. Sometimes when you read a response from some HTTP call it goes like this.
AND. This is wrong, by wrong I mean it can literally leak lots of memory and not only.
 
Can you tell what's wrong?
 
[Let's make it interactive! Please state on YT comments what's wrong here (:)]

[C] Yes, so the are two problems here

First is that we never close response body, which means you don't release the HTTP connection, so it cannot be used in later step
and will keep some go routines in net/http.

Second is that if either during scan or during error case we just  return, the body might be not fully read. 
And this is a problem because Body is   io.Reader which can be fetching bytes directly from network, so if you never read
or exhauset the reader, they might never released.

This is pretty common problem, it's not obvious and super easy to forget.
 
And you can avoid this problem with following changes:

---
@snap[north span-95 text-05 text-left padded]
##### Few optimization tricks & pitfalls @emoji[bomb]
@snapend

@snap[south-east span-100 text-06 text-gray]
Ensure you close and exhaust the body. This actually can read from network directly!                       
@snapend

@code[golang code-noblend code-max zoom-10](slides/optimizing-go-for-clouds-go-meetup/leak.go?lines=25-42)

@[5-8]

Note:

Just ensure you defer reading full body and closing it.
And if this code is not clean or pretty for you, which is fair, you can check the helper we created for this.

---
@snap[north span-95 text-05 text-left padded]
##### Few optimization tricks & pitfalls @emoji[bomb]
@snapend

@snap[south-east span-100 text-06 text-gray]
Feel free to use Thanos [github.com/thanos-io/thanos/pkg/runutil](https://pkg.go.dev/github.com/thanos-io/thanos@v0.11.0/pkg/runutil?tab=doc) package                    
@snapend

@code[golang code-noblend code-max zoom-10](slides/optimizing-go-for-clouds-go-meetup/leak.go?lines=44-58)

@[5]

Note: 

From runutil package, called very lengthy ... it exactly does the same, plus it properly return error from this operation as well 

---
@snap[north span-95 text-05 text-left padded]
##### Few optimization tricks & pitfalls @emoji[bomb]
@snapend

@snap[south-east span-100 text-06 text-gray]
This code can allocate a lot and use more CPU than needed for growing array.
@snapend

@code[golang code-noblend code-max zoom-10](slides/optimizing-go-for-clouds-go-meetup/alloc.go?lines=3-11)

@[5-6]

Note:

Second tip is related to creating slices and maps, so overall arrays.
This code might be very slow and allocate more than you want.

Anyone can you tell what's wrong?

[C] Ok the problem is in this part. We append one by one. This is not the best, as Go wants to grow 
underlying arrays for you in small steps. So usually it means, it will allocate two items, then you append one more,
it allocates twice more and copy old array into new memory slot.
Few more, it again allocates 8 and copy things over. If you put 9, it doubles again, and copies.

You can see where it goes for millions of elements.

And runtime does it step by step, because it does not want to overallocate!

So what's the solution?

---
@snap[north span-95 text-05 text-left padded]
##### Few optimization tricks & pitfalls @emoji[bomb]
@snapend

@snap[south-east span-100 text-06 text-gray]
It's a good pattern to pre-allocate Go arrays! You can do that using `make()`
@snapend

@code[golang code-noblend code-max zoom-10](slides/optimizing-go-for-clouds-go-meetup/alloc.go?lines=13-23)

@[2-3,6,8]

Note:

Be nice to Go runtime, and tell ahead the runtime how many items you will add to both slice and map, especially if 
have this information because we are literally copy the array. All thanks to make statement, which takes
number of elements for length pre-grow.
 
---
@snap[north span-95 text-05 text-left padded]
##### Few optimization tricks & pitfalls @emoji[bomb]
@snapend

@snap[south-east span-100 text-06 text-gray]
We are hitting problem with lazy GC, and we allocate more than needed.
@snapend

@code[golang code-noblend code-max zoom-10](slides/optimizing-go-for-clouds-go-meetup/reuse.go?lines=4-16)

@[7-11]

Note:

Last optimization I want to show is this snippet, I kind of comment what's wrong. It essentially allocates more than
needed.

[C] so the problem is line 11, and this is because we allocate new string slice evey time we split message by max Lenghth.

---
@snap[north span-95 text-05 text-left padded]
##### Few optimization tricks & pitfalls @emoji[bomb]
@snapend

@snap[south-east span-100 text-06 text-gray]
Reusing the same slice to avoid allocation is nice here.
@snapend

@code[golang code-noblend code-max zoom-10](slides/optimizing-go-for-clouds-go-meetup/reuse.go?lines=19-30)

@[7-10]


Note:
Instead it might be better to just reset slice in this form, as this is cutting the slice and resets its length to zero, however
still maintaing underlying array!

---

@snap[north span-95 text-05 text-left padded]
##### Summary
@snapend

@snap[south-east span-95 padded]
![width=150](assets/images/slides/SPACEGIRL1.png)
@snapend

@snap[north span-100]
<br/>
@ol[span-90 text-06](true)
1. Resist the excuses, optimize Go code to solve your performance bottlenecks!
1. Three steps process: **First: define the problem and find bottleneck** 
1. **Second: Find the right balance, a tradeoff. What's more important?**
1. **Third: Optimize & Measure, ensure Data Driven Decisions**
1. Code suggestions, find more in [Thanos Go Style Guide!](https://thanos.io/contributing/coding-style-guide.md/#development-code-review)
@olend
@snapend

@snap[south-west span-100 padded fragment]
<br/>
![width=600](assets/images/slides/bench.png)
@snapend

@snap[south span-100 padded fragment]
<br/>
![width=500](assets/images/slides/tweet1.png)
@snapend

@snap[west span-100 padded fragment]
![width=500](assets/images/slides/tweet2.png)
@snapend

@snap[east span-100 padded fragment]
![width=450](assets/images/slides/tweet3.png)
@snapend

Note:

So let's sum up what we learned today:

1. There are many excused to ignore optimizing our Go code, but resist, but with healthy balance!
1. Next, the 3 step process! Don't overwork. Focus on critical paths and your biggest bottlenecks, we don't need to save all the tiny CPU 
cycles and allocation in our programs.
1. Choose your tradeoff wisely, You want faster execution, probably you would need more memory space.
1. Base your code decision on real data! Either micro-benchmarks on e2e load tests are must have.
1. And after all feel free to try the optimization suggestions I gave, and you can find more in our Thanos GO style guide!

Anyway, all this talk, and all this kind of complext work - we to see at the end of your day following things
 
[C] the major bugs that single bigger optimiation solved for people, and seeing the happiness
[C][C] on twitter thanks to optimizations 

It might be worth it!

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
#### Sources & Credits
@snapend

@snap[midpoint span-75 text-06 text-bold text-left]
@ol[](false)
* Amazing [ashleymcnamara](https://github.com/ashleymcnamara/gophers) gophers
* [viva64](https://www.viva64.com/en/t/0084/#:~:text=Definition%20and%20Properties,performs%20fewer%20input%2Foutput%20operations.)
* [wiki.c2.com](http://wiki.c2.com/?RulesOfOptimization)
* [pprof](https://jvns.ca/blog/2017/09/24/profiling-go-with-pprof/)
* [Dave's bench tutorial](https://dave.cheney.net/2013/06/30/how-to-write-benchmarks-in-go)
* [Thanos Go Style Guide!](https://thanos.io/contributing/coding-style-guide.md/#development-code-review)
* [Amazing gitpitch framework for slide creation!](https://gitpitch.com/)
@olend
