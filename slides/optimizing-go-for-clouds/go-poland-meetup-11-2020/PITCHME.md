![drag=45 45, drop=50 25 true](assets/images/slides/GopherSpaceCommunity.png)

[drag=80, drop=50 60 true true]
### Optimizing Go for Clouds (and beyond @emoji[rocket])

[drag=80, drop=50 70 true true, set=text-italic]
#### Practical Intro

[drag=60, drop=0 -5 false true, set=text-italic, fit=0.7]
Poland | 26.11.2020 | [Golang Poland Meetup](https://www.meetup.com/Golang-Poland/events/274616031/) | [Bartłomiej Płotka](https://bwplotka.dev) 

Note:
Thanks .., Hello everyone! I am super excited to be presenting today, in our ... Meetup.
I was very often joining this meetup as a guest, so I am triple honoured now to share what I know about Go and Performance from practical
side. I am speaking from the virtual stage and I wish we could meet in reality, but let's focus on benefits of this situation:
---

[drag=80, drop=50 7 true true, set=align-left]
### Optimizing Go for Clouds (and beyond @emoji[rocket])

![drag=35 35, drop=70 -25 true](assets/images/slides/GopherSpaceMentor.png)

[drag=80, drop=50 -40 true false, set=align-left]
###### Agenda:

[drag=80, drop=50 50 true true, set=align-left]
@ol[list-spaced-bullets](true)
1. Should you optimize your code for performance? _"Our design is scalable, machines big and code has to be readable, let's not worry about performance"_ @note[First of all, we will touch on the potential misconception, so essentially why performance for single application is still quite important nowadays and why you don't need to sacrifice readability!]
1. How to approach performance optimizations in Go? @note[Then we will discuss how to efficiently approach performance, how to start with optimizing and when]
1. Go optimization tricks & pitfalls @emoji[bomb] @note[Last but not the least I would love to share some tricks and usual patterns that helps improve things! But before that.. short introduction INTERACTIVITY]
@olend

Note:

---?include=slides/common/whoami-go/PITCHME.md

---
[drag=80, drop=50 7 true true, set=align-left]
### Code Optimization

![drag=20 20, drop=80 20 true true](assets/images/slides/SPACEGIRL1.png)

[drag=80, drop=50 50 true true, set=align-left]
@quote[Code optimization is any method of code modification to improve code quality and efficiency. A program may be optimized so that it becomes a smaller size, consumes less memory, executes more rapidly, or performs fewer input/output operations.]()

[drag=80, drop=50 80 true true, fit=0.8, set=align-left text-italic fragment]
*Soft Requirement: An optimized program must have the same output and side effects as its non-optimized version.

Note:

Let's start our optimization journey with definition!

a code optimization is essentially a method of changing the code in a way to improve something. Maybe smaller binary size, maybe
to make program faster or use less memory.

There is actually on soft requirement: is that an optimized program must have the same output and
side effects as its non-optimized version. This requirement, however, is soft. As it may be ignored,
in the case that the benefit from optimization is estimated to be more important than keeping the same output!

---
[drag=90, drop=50 7 true true, set=align-left]
### Should you optimize code for performance?

[drag=90, drop=50 25 true true, fit=0.8, set=align-left]
@quote[ We don't need to optimize this program because...<br/><br/>](Your Code Reviewer)

[drag=90 10, drop=50 25 true true, fit=0.8, set=fragment align-right text-yellow text-italics]
...we are just guessing here, this is just a micro-optimization!

![shadow, drag=50 70, drop=10 30, set=fragment](assets/images/slides/premature_opt2.jpg)

![shadow, drag=30 50, drop=60 40, stretch=true, set=fragment](assets/images/slides/premature_opt3.jpg)

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
[drag=90, drop=50 7 true true, set=align-left]
### Should you optimize code for performance?

[drag=90, drop=50 25 true true, fit=0.8, set=align-left]
@quote[ We don't need to optimize this program because...<br/><br/>](Your Code Reviewer)

[drag=90 10, drop=50 25 true true, fit=0.8, set=align-right text-yellow text-italics]
...we are just guessing here, this is just a micro-optimization!

![shadow, drag=50 70, drop=10 30, opacity=0.5](assets/images/slides/premature_opt2.jpg)

![shadow, drag=30 50, drop=60 40, stretch=true, opacity=0.5](assets/images/slides/premature_opt3.jpg)

[drag=80 30, drop=50 60 true true, set=padded bg-gold align-left]
Yes! Keep it simple **but** maintain **basic Go hygiene** (from start!)

* Use healthy **Go patterns consistently**
* Avoid basic pitfalls causing **leaks** and **major over-allocations**
* Monitor basic resources utilization for **extremes** @emoji[bomb]

Note:

I would say yes, while premature optimizations are evil there are some basic Go patterns you can stick to, in order to avoid basic performance pitfalls
I hopefully can list some of the tricks near the finish of this presentation.

---
[drag=90, drop=50 7 true true, set=align-left]
### Should you optimize code for performance?

[drag=90, drop=50 25 true true, fit=0.8, set=align-left]
@quote[ We don't need to optimize this program because...<br/><br/>](Your Code Reviewer)

[drag=90 10, drop=50 25 true true, fit=0.8, set=align-right text-yellow text-italics fragment]
...we mainly care about readability, let's not obfuscate our code!

[drag=80 70, drop=50 62 true true, fit=0.6, set=fragment]
@code[golang, fit=0.8](slides/optimizing-go-for-clouds/go-poland-meetup-11-2020/perf.go?lines=31-51,58-60)
_[Snippet Thanos Go code for lookup of label names in memory-mapped file](https://github.com/thanos-io/thanos/blob/63ef382fc335969fa2fb3e9c9025eb0511fbc3af/pkg/block/indexheader/binary_reader.go#L841)_ 

![shadow, drag=80, drop=80 60 true, set=fragment](assets/images/slides/readable.jpg)

@[22-24, zoom-15]

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
[drag=90, drop=50 7 true true, set=align-left]
### Should you optimize code for performance?

[drag=90, drop=50 25 true true, fit=0.8, set=align-left]
@quote[ We don't need to optimize this program because...<br/><br/>](Your Code Reviewer)

[drag=90 10, drop=50 25 true true, fit=0.8, set=align-right text-yellow text-italics]
...we mainly care about readability, let's not obfuscate our code!

[drag=80 70, drop=50 62 true true, opacity=0.5, fit=0.6]
@code[golang, fit=0.8](slides/optimizing-go-for-clouds/go-poland-meetup-11-2020/perf.go?lines=31-51,58-60)
_[Snippet Thanos Go code for lookup of label names in memory-mapped file](https://github.com/thanos-io/thanos/blob/63ef382fc335969fa2fb3e9c9025eb0511fbc3af/pkg/block/indexheader/binary_reader.go#L841)_ 

![shadow, drag=80, drop=80 60 true, opacity=0.5](assets/images/slides/readable.jpg)

[drag=80 30, drop=50 60 true true, set=padded bg-gold align-left]
Fair point, but with good abstractions, __balance__ and strict __consistency__, code can stay readable!

Note:

I would again advocate yes - performance still matter as there are ways to have performant and still readable Go code. Especially if we 
consider certain performance patterns, to be used consistently across the code, maybe even yoloString, so it's not longer surprising.

---
[drag=90, drop=50 7 true true, set=align-left]
### Should you optimize code for performance?

[drag=90, drop=50 25 true true, fit=0.8, set=align-left]
@quote[ We don't need to optimize this program because...<br/><br/>](Your Code Reviewer)

[drag=90 10, drop=50 25 true true, fit=0.8, set=align-right text-yellow text-italics fragment]
...our machines have [224 CPU cores and 24 TBs of RAM](https://aws.amazon.com/ec2/instance-types/high-memory/)

![shadow, drag=60, drop=30 60 true, set=fragment](assets/images/slides/aws-machines.png)

![shadow, drag=40, drop=70 60 true, stretch=true, set=fragment](assets/images/slides/brute-force.jpeg)

Note:

Other excuse, we hear the comment that we just have all the computing power needed, so why we should focus on performance. And that's a solid
statement in some cases. 

[C] For example AWS has those epic, huge bare metal servers available for you, and there are companies happy 
to pay for those.

[C] And that gives this impression that we don't need to focus on code performance much, we can just do whatever, it should not matter.

---

[drag=90, drop=50 7 true true, set=align-left]
### Should you optimize code for performance?

[drag=90, drop=50 25 true true, fit=0.8, set=align-left]
@quote[ We don't need to optimize this program because...<br/><br/>](Your Code Reviewer)

[drag=90 10, drop=50 25 true true, fit=0.8, set=align-right text-yellow text-italics]
...our machines have [224 CPU cores and 24 TBs of RAM](https://aws.amazon.com/ec2/instance-types/high-memory/)

![shadow, drag=60, drop=30 60 true, opacity=0.5](assets/images/slides/aws-machines.png)

![shadow, drag=40, drop=70 60 true, stretch=true, opacity=0.5](assets/images/slides/brute-force.jpeg)

[drag=80 30, drop=50 60 true true, set=padded bg-gold align-left]
This is not that easy: __Slow garbage collections for huge heaps__ and __multicore architecture "fun"__: 
races, IO, network, memory bandwidth saturations etc, add huge complexity and brings limits quite early.


Note:
Well, in practice it's not that nice as it looks.
 
Concurrent programming is hard, despite Go having pretty amazing framework for it.
With lots of go routines and channels, you will hit process scalability limitation at some point. Think about cases like resource starvation or 
garbage collection latency on an enormous heap so shared memory across go routines. 

Not mentioning other aspects like memory or disk IO bandwidth. 
At the end you have to optimize the code in some way or scale out of the single process and do the operations efficiently.

---
[drag=90, drop=50 7 true true, set=align-left]
### Should you optimize code for performance?

[drag=90, drop=50 25 true true, fit=0.8, set=align-left]
@quote[ We don't need to optimize this program because...<br/><br/>](Your Code Reviewer)

[drag=90 10, drop=50 25 true true, fit=0.8, set=align-right text-yellow fragment]
@css[text-italics](...there is no need, our system scales horizontally) 🤷

![drag=30 80, drop=10 60 false true, set=fragment](assets/images/slides/scaleup.gif)
[drag=30 10, drop=10 -10 false true, set=fragment]
Vertical Scalability

Note:

What we tried previously is a scale up proces, so adding more resources to single machine? 
More CPU, RAM, better network, but usually it's just single process, single machine

  
---
[drag=90, drop=50 7 true true, set=align-left]
### Should you optimize code for performance?

[drag=90, drop=50 25 true true, fit=0.8, set=align-left]
@quote[ We don't need to optimize this program because...<br/><br/>](Your Code Reviewer)

[drag=90 10, drop=50 25 true true, fit=0.8, set=align-right text-yellow]
@css[text-italics](...there is no need, our system scales horizontally) 🤷

![drag=30 80, drop=10 60 false true, opacity=0.5](assets/images/slides/scaleup.gif)
[drag=30 10, drop=10 -10 false true, opacity=0.5]
Vertical Scalability

![drag=30 80, drop=60 60 false true](assets/images/slides/scaleout.gif)
[drag=30 10, drop=60 -10 false true]
Horizontal Scalability

![shadow, drag=40 80, drop=15 60 false true, fragment](assets/images/slides/microservices.jpg)

Note:


But there is another excuse! Why should we invest time in code optimizations if we can just things
horizontaly??

And particularly in this model someone can say that optimizing single process is not a priority, because
if your operations need more resources because of bigger traffic, you can just add another server or virtual machine or container etc
shard more distribute traffic more!

The problem is that horizontal scalability became a buzz word, a certain "fashion". And this problem, misconception
is actually the true motivation for me for making this presentation. 

Because scale-out fashion, is maybe more exciting for engineers? caused many people to really sometimes **prematurely** dive into distributing
their application and using tools like Kubernetes, Mesos, OpenStack etc. 


---
[drag=90, drop=50 7 true true, set=align-left]
### Should you optimize code for performance?

[drag=90, drop=50 25 true true, fit=0.8, set=align-left]
@quote[ We don't need to optimize this program because...<br/><br/>](Your Code Reviewer)

[drag=90 10, drop=50 25 true true, fit=0.8, set=align-right text-yellow]
@css[text-italics](...there is no need, our system scales horizontally) 🤷

![drag=30 80, drop=10 60 false true, opacity=0.5](assets/images/slides/scaleup.gif)
[drag=30 10, drop=10 -10 false true, opacity=0.5]
Vertical Scalability

![drag=30 80, drop=60 60 false true, opacity=0.5](assets/images/slides/scaleout.gif)
[drag=30 10, drop=60 -10 false true, opacity=0.5]
Horizontal Scalability

![shadow, drag=40 80, drop=15 60 false true, opacity=0.5](assets/images/slides/microservices.jpg)

[drag=80 30, drop=50 60 true true, set=padded bg-gold align-left]
__Performance still matters__. Distributed Systems are... complex, over consuming is expensive, cold starts, etc...

![shadow, drag=30 80, drop=60 80 false true](assets/images/slides/doesnotsimply.jpg)

Note:

So I want to reiterate, performance still matters. Horizontal scaling can be extremely expensive and difficult to implement properly.
Not mentioning overhead and delay in scaling this way, especially if the Go code is not optimized.

And that's despite the fact that they can quickly optimize a couple of critical paths, unnecessary allocation in their code and allow single-process Go application 
to serve thousands of users without issues.    

---
[drag=90, drop=50 7 true true, set=align-left]
### How to approach performance optimizations?

![drag=20 20, drop=20 80 true true](assets/images/slides/SPACEGIRL_GOPHER.png)

[drag=80, drop=50 20 true true, set=text-bold, set=fragment]
Step 1: Define __the problem__; find __the bottleneck__.

[drag=80, drop=50 50 true true, set=align-left fragment]
@quote[<br/>1. First rule of Optimization: Don't do it.<br/>2. Second rule of Optimization: Don't do it... yet.<br/>3. Profile before Optimizing](http://wiki.c2.com/?RulesOfOptimization) 

Note:

OK hopefully I motivate you a bit to think about performance improvements for your  Go app, so

So, how to approach this topic? 

[C] First and foremost: Step number one! Detect the bottleneck, find the problem you want to solve.  

[C] There is a good rule related to premature optimization as touched before: Don't do any peformance changes if they are not needed
now or in near future actually

There are probably more important things you can spend your time on. 

---
[drag=90, drop=50 7 true true, set=align-left]
### How to approach performance optimizations?

![drag=20 20, drop=20 80 true true](assets/images/slides/SPACEGIRL_GOPHER.png)

[drag=80, drop=50 20 true true, set=text-bold]
The Problem: API / RPC / Command / Action execution is...

[drag=40 10, drop=25 30 true true, fit=0.8, set=align-center fragment]
a) @emoji[watch] Very slow or time-outs.

[drag=40 10, drop=75 30 true true, fit=0.8, set=align-center fragment]
b) @emoji[fire] Crashing the machine or process is killed before succeeding.

[drag=40 60, drop=25 65 true true, fit=0.8, set=align-center fragment]
![shadow](assets/images/slides/compressible.gif)
@size[0.8em](e.g CPU time, Disk IO, Memory IO, Network IO) 

Note:

This sounds solid, but how to do that, how it looks in practice? Well, usually you don't find the problem, the problem finds you!!

Generally things you can potentially solve by optimizing your Go code can be divided into two groups: 

[C] [C] (...)

What's the difference? Well both symptoms are actually because of the same reason: host that process is running on does not have enough resources to
perform the operation. The difference between these two is actually in the characteristics of the underlying resource that is saturated (not enough of it).

[C] First one is compressible resources like.. Those the resources you can throttle temporarily without stopping the program. This usually means freezing execution
or slowing it down.

---
[drag=90, drop=50 7 true true, set=align-left]
### How to approach performance optimizations?

![drag=20 20, drop=20 80 true true](assets/images/slides/SPACEGIRL_GOPHER.png)

[drag=80, drop=50 20 true true, set=text-bold]
The Problem: API / RPC / Command / Action execution is...

[drag=40 10, drop=25 30 true true, fit=0.8, set=align-center]
a) @emoji[watch] Very slow or time-outs.

[drag=40 10, drop=75 30 true true, fit=0.8, set=align-center]
b) @emoji[fire] Crashing the machine or process is killed before succeeding.

[drag=40 60, drop=25 65 true true, fit=0.8, opacity=0.5, set=align-center]
![](assets/images/slides/compressible.gif)
@size[0.8em](e.g CPU time, Disk IO, Memory IO, Network IO) 

![drag=32 60, drop=75 62 true true](assets/images/slides/incompressible.gif)

[drag=40 60, drop=75 90 true true, fit=0.8, set=align-center]
@size[0.8em](e.g Storage: Memory, Disk, or DB Space, Power) 

Note:

[C] Second are incompressible resources Those you cannot throttle without causing a failure. For example if process requires more memory and there is none, 
Linux kernel has to kill such offending process as nothing better can be really done. 

It terminates that process which is popularly known as OOM or out of memory exception.

This is quite important differentiations and will help you to tell what kind of bottleneck you should solve first while optimizing Go program.

---
[drag=90, drop=50 7 true true, set=align-left]
### How to approach performance optimizations?

![drag=20 20, drop=20 80 true true](assets/images/slides/SPACEGIRL_GOPHER.png)

[drag=80, drop=50 20 true true, set=text-bold]
The bottleneck: What operation (part of the code) causes undesired resource consumption?

[drag=90 10, drop=50 30 true true, fit=0.8, set=align-center fragment]
a) @emoji[watch] Execution is very slow or time-outs.

[drag=80 60, drop=50 65 true true, fit=0.8, flow=stack, set=align-center fragment]
Symptom: Alert (e.g via [Alertmanager](https://prometheus.io/docs/alerting/latest/alertmanager/))
![shadow](assets/images/slides/querylatency.png)
Drill down 1: Metrics via [Prometheus](https://prometheus.io) and [Grafana](https://grafana.com/) dashboards. 
![shadow](assets/images/slides/duration.png)
Drill down 2: Traces via [Jaeger](https://www.jaegertracing.io/). 
![shadow](assets/images/slides/Trace.png)
Drill down 3a: Profiling via [pprof](https://jvns.ca/blog/2017/09/24/profiling-go-with-pprof/) CPU [Flamegraph](http://www.brendangregg.com/flamegraphs.html) 
![shadow](assets/images/slides/flame.png)
Drill down 3b: Profiling via [pprof](https://jvns.ca/blog/2017/09/24/profiling-go-with-pprof/) CPU Profile
![shadow](assets/images/slides/profile1.png)

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
[drag=90, drop=50 7 true true, set=align-left]
### How to approach performance optimizations?

![drag=20 20, drop=20 80 true true](assets/images/slides/SPACEGIRL_GOPHER.png)

[drag=80, drop=50 20 true true, set=text-bold]
The bottleneck: What operation (part of the code) causes undesired resource consumption?

[drag=90 10, drop=50 30 true true, fit=0.8, set=align-center]
a) @emoji[fire] Execution is crashing the machine or process is killed before succeeding.

[drag=80 60, drop=50 65 true true, fit=0.8, flow=stack, set=align-center fragment]
Symptom: Process is crashing e.g on [Kubernetes](http://kubernetes.io/) (via [OpenShift Console](https://www.redhat.com/en/technologies/cloud-computing/openshift/try-it?sc_cid=7013a000002DkSqAAK&gclid=CjwKCAjw_qb3BRAVEiwAvwq6VtRhQegkDHNqedqfhFpGxGhhTxf3PJ4gTrlt5R9baahwYrAu5qgWyRoC_FcQAvD_BwE&gclsrc=aw.ds))
![shadow](assets/images/slides/crashloop.png)
Drill down 1: Metrics via [Prometheus](https://prometheus.io) and [Grafana](https://grafana.com/) dashboards. 
![shadow](assets/images/slides/memory.png)
Drill down 2: Traces?
Drill down 2: Traces? @css[text-pink](Not really useful, it's not latency issue...)
Drill down 2: Profiling? 
Drill down 2: Profiling? @css[text-pink](Profiling what, process already crashed...)
Drill down 2: __Continous Profiling__! via [ConProf](https://github.com/conprof/conprof) (check good intro [here](https://youtu.be/kRVE15j1zxQ?t=221))
![shadow](assets/images/slides/conprof.png)


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
[drag=90, drop=50 7 true true, set=align-left]
### How to approach performance optimizations?

![drag=20 20, drop=50 80 true true](assets/images/slides/SPACEGIRL_GOPHER.png)

[drag=80, drop=50 20 true true, set=text-bold]
Step 2: Find the right balance, a _tradeoff_.

[drag=80, drop=50 60 true true, set=text-bold]
What's more important?</br>🤔

[drag=30 10, drop=20 40 true true]
@box[span-90 rounded bg-gold box-padded](CPU)

[drag=30 10, drop=80 40 true true]
@box[span-90 rounded bg-purple box-padded](Memory)

[drag=30 10, drop=20 60 true true]
@box[span-90 rounded bg-green box-padded](Disk)

[drag=30 10, drop=80 60 true true]
@box[span-90 rounded bg-blue box-padded](Network)

[drag=30 10, drop=20 80 true true]
@box[span-90 rounded bg-gray box-padded](Functionality)

[drag=30 10, drop=80 80 true true]
@box[span-90 rounded bg-pink box-padded](Readability)

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
[drag=90, drop=50 7 true true, set=align-left]
### How to approach performance optimizations?

[drag=80, drop=50 20 true true, set=text-bold]
Step 3: Optimization Effectiveness vs Effort.

[drag=80, drop=50 55 true true, set=fragment]
![](assets/images/slides/pyramid.png)

Note:

---
[drag=90, drop=50 7 true true, set=align-left]
### How to approach performance optimizations?

[drag=80, drop=50 20 true true, set=text-bold]
Step 4. Optimize & Measure: Ensure __Data Driven__ Decisions.

[drag=80, drop=50 55 true true, set=fragment]
![](assets/images/slides/Measurement.png)

[drag=80, drop=50 90 true true, fit=0.8, set=fragment]
@ol[list-spaced-bullets text-08](true)
1. Benchmarks ("micro-benchmarks"): [go test -bench](https://dave.cheney.net/2013/06/30/how-to-write-benchmarks-in-go), [benchcmp old new](https://godoc.org/golang.org/x/tools/cmd/benchcmp), [benchstat](https://godoc.org/golang.org/x/perf/cmd/benchstat), [funcbench](https://github.com/prometheus/test-infra/tree/master/funcbench)
1. Load Tests ("macro-benchmarks"): [prombench](https://github.com/prometheus/test-infra/tree/master/prombench), Kubernetes + Prometheus, [perf](http://www.brendangregg.com/perf.html)
@olend

Note:

So finally! Our problem is defined, exact bottleneck found the we agreed on direction of our optimization. N

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
[drag=90, drop=50 7 true true, set=align-left]
### Performance optimization tricks & pitfalls @emoji[bomb]

[drag=80 10, drop=50 90 true true, fit=0.8, set=fragment align-left]
Pitfall 1 "__Reading HTTP Response__": this code is __leaking memory__ in net/http package. Do you know why?

@code[golang code-noblend code-max zoom-10, drag=80 60, drop=50 50 true true, fit=0.7, set=fragment](slides/optimizing-go-for-clouds/go-poland-meetup-11-2020/leak.go?lines=12-23)

@[6,7-8,10-11]

Note:

That was theory! Now for last 5 minutes, let's jump into a few optimization tricks you can apply generally.

First one is related to the standard net/http package. Sometimes when you read a response from some HTTP call it goes like this.
AND. This is wrong, by wrong I mean it can literally leak lots of memory and not only.
 
Can you tell what's wrong?
 
[Let's make it interactive! Please state on YT comments what's wrong here (:)]

[C] Yes, so the are two problems here

First is that we never close response body, which means you don't release the HTTP connection, so it cannot be reused in for other incomingh connection,
the server has to create new TCP connection which is slow and takes extra resources. 

Second problem is that if either during scan or during error case we just return, the body might be not fully read. 
And this is a problem because Body is actually an io.Reader which can be fetching bytes directly from network, so if you never read
or exhauset the reader, you never read those bytes - this memory might be never released.

This is pretty common problem, it's not obvious and super easy to forget.
 
And you can avoid this problem with following changes:

---
[drag=90, drop=50 7 true true, set=align-left]
### Performance optimization tricks & pitfalls @emoji[bomb]

[drag=80 20, drop=50 90 true true, fit=0.8, set=align-left]
Tip 1: Ensure you __close and exhaust the body__. Otherwise, the bytes are never read from the buffers (often channels), so go-routintes are left, sockets and connections are never reused.                        

@code[golang code-noblend code-max zoom-10, drag=80 60, drop=50 50 true true, fit=0.6, set=fragment](slides/optimizing-go-for-clouds/go-poland-meetup-11-2020/leak.go?lines=25-42)

@[5-8]

Note:

[C]!

Just make sure that you defer reading full body and closing it.
And if this code is not clean or pretty for you, which is fair, you can check the helper we created for this.

---
[drag=90, drop=50 7 true true, set=align-left]
### Performance optimization tricks & pitfalls @emoji[bomb]

[drag=80 20, drop=50 90 true true, fit=0.8, set=align-left]
Feel free to use Thanos [github.com/thanos-io/thanos/pkg/runutil](https://pkg.go.dev/github.com/thanos-io/thanos@v0.11.0/pkg/runutil?tab=doc) package                    

@code[golang code-noblend code-max zoom-10, drag=80 60, drop=50 50 true true, fit=0.6, set=fragment](slides/optimizing-go-for-clouds/go-poland-meetup-11-2020/leak.go?lines=44-58)

@[5]

Note: 

[C]!

inside Thanos runutil package. The name is quite lengthy ... but it does what needed and
properly return error if this operation fails which is nice! 

---
[drag=90, drop=50 7 true true, set=align-left]
### Performance optimization tricks & pitfalls @emoji[bomb]

[drag=80 20, drop=50 90 true true, fit=0.8, set=align-left]
Pitfall 2 "__Copy Slide Into Slice and Map__": This code __allocates more memory and use more CPU__ than needed. Where?

@code[golang code-noblend code-max zoom-10, drag=80 60, drop=50 50 true true, fit=0.6, set=fragment](slides/optimizing-go-for-clouds/go-london-meetup-06-2020/alloc.go?lines=3-11)

@[5-6]

Note:

Second potential pitfall is related to creating slices and maps, so overall Go arrays.
We want to copy a slice into another slice and map. And this code might be very slow and allocate more than you want.

Anyone can you tell what's wrong?

[C] Ok the problem is in this part. We append one by one. This is not the best, as Go wants to grow 
underlying arrays for you in small steps. So usually it means, it will allocate two items, then you append one more,
it allocates twice more and copy old array into new memory slot.
Few more, it again allocates 8 and copy things over. If you put 9, it doubles again, and copies.

You can see where it goes for millions of elements.

And runtime does it step by step, because it does not want to overallocate!

So what's the solution?

---
[drag=90, drop=50 7 true true, set=align-left]
### Performance optimization tricks & pitfalls @emoji[bomb]

[drag=80 20, drop=50 90 true true, fit=0.8, set=align-left]
Tip 2: It's a good pattern to pre-allocate Go arrays! You can do that using `make()`

@code[golang code-noblend code-max zoom-10, drag=80 60, drop=50 50 true true, fit=0.6, set=fragment](slides/optimizing-go-for-clouds/go-london-meetup-06-2020/alloc.go?lines=13-23)

@[2-3,6,8]


Note:

[C]!

...Be nice to the Go runtime, and tell ahead the runtime how many items you will add to both slice and map, especially if 
have this information because we are literally copy the array. 

All thanks to make statement, which takes number of elements for length pre-grow.

---
[drag=90, drop=50 7 true true, set=align-left]
### Performance optimization tricks & pitfalls @emoji[bomb]

[drag=80 20, drop=50 90 true true, fit=0.8, set=align-left]
Pitfall 3 "__Continuous Marshalling__": We allocate and create __CPU pressure more than needed__. Can you see why?

@code[golang code-noblend code-max zoom-10, drag=80 60, drop=50 50 true true, fit=0.6, set=fragment](slides/optimizing-go-for-clouds/go-london-meetup-06-2020/reuse.go?lines=4-12)

@[7]

Note:

Last optimization I want to show is this snippet, I kind of commented what's wrong, so no point in guessing.
It essentially allocates more than needed.


[C] We are hitting problem with lazy GC, and we allocate more than needed.
so the problem is that we allocate new string slice evey time we split message by max lenghth. In theory old allocated slice should
be released from memory by garbage collection, but this collection happens periodically so it will lag behind and leaving lot's 
of extra memory used.

---
[drag=90, drop=50 7 true true, set=align-left]
### Performance optimization tricks & pitfalls @emoji[bomb]

[drag=80 20, drop=50 90 true true, fit=0.8, set=align-left]
Tip 3: Reuse the same slice if you can!

@code[golang code-noblend code-max zoom-10, drag=80 60, drop=50 50 true true, fit=0.6, set=fragment](slides/optimizing-go-for-clouds/go-london-meetup-06-2020/reuse.go?lines=15-26)

@[7-10]

Note:

[C]!

What's the solution? instead it might be better to just reset slice in this form This is cutting the slice and resets its length to zero, however
still maintaing underlying array!

---
[drag=90, drop=50 7 true true, set=align-left]
### Summary

![drag=20 20, drop=80 20 true true](assets/images/slides/SPACEGIRL1.png)

@ol[drag=90](true)
1. Resist the excuses, consider optimizing Go code to solve your performance bottlenecks!
1. **First: Define the problem and find the main bottleneck** 
1. **Second: Find the right balance, a tradeoff. What's more important?**
1. **Third: Understand the effort**
1. **Fourth: Optimize & Measure, ensure Data Driven Decisions**
1. Remember about tips, find more in [Thanos Go Style Guide!](https://thanos.io/contributing/coding-style-guide.md/#development-code-review)
@olend

![drag=90, drop=50 50 true true, set=fragment](assets/images/slides/bench.png)

![drag=90, drop=50 50 true true, set=fragment](assets/images/slides/tweet1.png)

![drag=90, drop=50 50 true true, set=fragment](assets/images/slides/tweet2.png)

![drag=90, drop=50 50 true true, set=fragment](assets/images/slides/tweet3.png)

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

---?include=slides/common/thank-you/PITCHME.md