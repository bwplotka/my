---
weight: 1
date: 2020-09-06
linktitle: "Announcing Our Book with O'Reilly: Efficient Go!"
title: "Announcing Our Book with O'Reilly: Efficient Go!"
date: 2021-09-07
authors:
- name: "Bartek Płotka"
featuredImage: "/og-images/efficientgo.png"
type:
- post
- posts
categories:
- go
- open-source
- efficient-go
---

> TL;DR: I am super excited to announce an exact topic of our book we write together with O'Reilly publisher. "Efficient Go" will consist of 10 chapters, including one from the amazing [Frederic Branczyk](https://twitter.com/fredbrancz)! The book is planned to be released near the end of Q1 2022. Stay Tuned! Join our Discord Community using this [link](https://discord.gg/3rCttps74F) or follow [@bwplotka](https://twitter.com/bwplotka) on Twitter if you want to get notified about updates, promotions, opportunities to contribute and events!

Almost exactly seven months ago, I announced that I will be writing a book with the publisher I have always admired, [O'Reilly](https://twitter.com/OReillyMedia). Since this time, the book development has started, a significant part was delivered, the topic has been clarified, and motivation is even stronger! Yet still, lots of work is ahead of us.

Today, I decided it is a great time to reveal more details on what I write about and with whom (there is a reason why I mention "our" book and "us"!). In this post, you will learn about book topics, motivation and what YOU can personally gain by following this work!

## What "Efficient Go" Book is About?

As the title suggests, "Efficient Go" book is about writing and maintaining truly "efficient" code written in probably the most productive language in the world, [Go](https://golang.org/). Readers will learn when to care about performance, execution latency and resource usage of their Go programs and when to save time avoiding unnecessary work. You will learn how to debug efficiency problems using open source tools like `go test`, `pprof`, `benchstat`, `k6.io`. How to maintain efficiency across versions using various observability tools. What are the common performance mistakes developers make in Go.

The premise is that there are often ways to optimize your code without significant impact on readability and simplicity, which is what we love in Go. This book is aimed primarily at everyday use cases of Go. All backend or app developers, full-stack engineers, testers, Site Reliability Engineers or DevOps will find something useful for their use cases. The majority of the book is NOT about hardcode, dangerous, low level, high-performance programming that we might imagine when hearing about "performance". This is also why we named this book "Efficient Go". It's about "efficient knowledge about efficiency". Nothing too crazy, rather something that, in my opinion, every Go programmer should know if they want to develop serious products, cloud services or desktop applications.

You can read more from the current version of our book abstract (published soon on [O'Reilly Early Access](https://www.oreilly.com/online-learning/individuals.html)):

> Software engineers today typically put performance optimizations low on the list of development priorities. But despite significant technological advancements and lower-priced hardware, software efficiency still matters. With this book, Go programmers will learn how to approach performance topics for applications written in this open source language.
>
> How and when should you apply performance efficiency optimization without wasting your time? Authors Bartlomiej Plotka and Frederic Branczyk provide the tools and knowledge you need to make your system faster using fewer resources. Once you learn how to address performance in your Go applications, you'll be able to bring small but effective habits to your programming and development cycles.
>
> This book shows you how to:
>
> * Continuously monitor for performance and efficiency regressions.
> * Find the root cause of performance bottlenecks using metrics, logging, tracing and profiling.
> * Use tools like `pprof`, `go test`, `benchstat` and `k6.io` to create reliable micro- and macro-benchmarks.
> * Improve and optimize your code to meet your goals without sacrificing simplicity and readability.
> * Make data-driven decisions by prioritizing changes that make a difference.
> * Introduce basic "performance hygiene" in day-to-day Go programming and testing.

## Gladly, I am Not Alone!

There are plenty of people who already contributed to our book's existing content, and I can't thank them enough for the past and future help! Also, thanks to the open-source communities I participate in, I was grateful to meet many amazing people, willing to sacrifice, often their free time, for this work.

In terms of content, I ([Bartek Płotka](https://www.bwplotka.dev/about/)) am the primary author of this book with nine chapters planned from my side. But I'm not alone! I am super happy to have [Frederic Branczyk](https://twitter.com/fredbrancz) joining "Efficient Go" with the chapter dedicated to [Profiling](https://www.polarsignals.com/blog/posts/2021/08/03/diy-pprof-profiles-using-go/)--a must-to-know technique when it comes to finding the efficiency bottlenecks quickly in your application. Frederic is my friend, experienced Go developer and Prometheus maintainer. As a CEO and founder of the [Polar Signals](https://www.polarsignals.com/), a start-up focused on bringing next level, continuous profiling to open source and as a service, there might be no better expert in this space! I am super excited about this contribution. I hope you are too!

I would also like to thank here [Michael Hausenblas](https://twitter.com/mhausenblas) and [Stefan Schimanski](https://twitter.com/the_sttts) who were super helpful in the early stages, things like choosing the publisher and process of writing book. Thanks to the O'Reilly team, especially my tech editor, Melissa! Additionally, kudos to my employer, Red Hat, who supports me in writing my book in my free time.

## My Honest Motivation Behind The "Efficient Go"

I can only speak about my motivation, but maybe you are curious why I do this to myself? Why did I decide to write a book?

> At my past job, a UK startup called Improbable, there used to be a certain Google Sheet around skills shared company-wide. In this spreadsheet, anyone could optionally state the level of expertise they have with selected technologies to indicate that either they want to learn something or can teach others or consult on difficult problems. Since it was "cloud gaming" company, there were things like Unity, Unreal, git, C, C++, Java, Go and more. In each category, you could choose from 0 to 10, how experienced you are, where 8 is very experienced, 9 means you were doing talks about it and 10 means that you wrote a book about the topic. I was very good at programming in Go, but I have always dreamed about being helpful to others in such a degree that it would deserve the `10` mark next to Go category... 🙃

On a more serious note, it might be indeed quite surprising to decide about book writing in the times where we are surrounded by short blog posts, social media, conference presentations, YouTube videos and TikTok. All of those mediums have their own pros and cons, but there is a common problem--they are... short. You can present maybe three important things about the topic in such a format. Still, some topics really deserve a broad breakdown of details for someone to understand things effectively (and not shoot themselves in the knee with half-baked information mixed with shady advice found on StackOverflow).

I believe software efficiency and performance, in general, is exactly such a topic. If you know only "some" elements, you can easily end up with an opposite than the desired effect. Slowing the application, creating leaks, losing enormous amounts of time on potentially not-effective micro-optimizations with a huge burden on code portability and maintenance. And ignoring slow code or overuse of resources (memory, disk, network, cloud services or even battery!) can result in losing concrete amounts of $$$ on computing power or customers.

How do I know that this topic is relevant? We all live in some kind of social bubble, but I was grateful to try many things in the past. 

* I was a developer doing PoCs (C++ & Go) with performance-related features (e.g. noisy neighbour aware scheduling, FPGA) around many open-source orchestration systems (OpenStack, Mesos, Kubernetes) at Intel. 
* I worked for few years as the Site Reliability Engineer, developing and operating hundreds of micro-services, written in Go and running on around 30-ish Kubernetes clusters around the globe. Debugging leaks due to losing pointers to unclosed HTTP request Body or CPU bombs due to Go variable shadowing bugs was always fun!
* As the core [Prometheus](https://prometheus.io/) maintainer, among other things, I [rewrote the majority of Prometheus storage code around iterators and added streaming remote read](https://github.com/prometheus/prometheus/issues?q=is%3Apr+author%3Abwplotka+is%3Aclosed) (trust me, writing time-series database is hard!).
* I co-created [Thanos](https://thanos.io/), the CNCF incubated project, written in Go that is now used by hundreds of companies and is capable of storing and [serving hundreds of millions](https://twitter.com/MichalekJuraj/status/1407756587759026181) of metric series across years.
* I am serving as the CNCF TAG Observability Tech Lead and CNCF Ambassador--where I am learning every week something new about the bigger picture and performance tradeoffs big observability systems are making.
* Within CNCF mentorship, I mentored dozens of students or new people in the open-source communities to develop in Go and build readable and efficient code.
* I work as an architect/SRE/backend developer in Red Hat, helping to maintain the OpenShift metrics ecosystem that now holds 11 billion series across thousands of clusters.
* I maintain many smaller open-source projects e.g [Prometheus client-go](https://github.com/prometheus/client_golang), [bingo](https://github.com/bwplotka/bingo), [go-grpc-middlewares](https://github.com/grpc-ecosystem/go-grpc-middleware), [mdox](https://github.com/bwplotka/mdox), [mimic](https://github.com/bwplotka/mimic), [e2e](https://github.com/efficientgo/e2e) and more! Some of them are used on critical performance paths in other production Go code.
* I even wrote our own [opinionated and stricter Go-style guide](https://thanos.io/tip/contributing/coding-style-guide.md/).

I worked with both experienced, ex-Google Go experts. I worked with people new to the language. I worked in huge mono-repos as well as scattered tiny Go projects. In close as well as open-source. In fast-paced startup as well as multi-org corporations. At some point, I realized that:

1. I am repeating myself. I am constantly explaining the same stuff about Go to other people. How to write Go, how to make it efficient, how to benchmark and observe performance. What are the common pitfalls (e.g [Go 1.12-1.15 sneaky memory release model](https://www.bwplotka.dev/2019/golang-memory-monitoring/)).
2. There is not many deep, up-to-date resources or literature about software efficiency and tooling, especially for every-day Go programming. Most of the knowledge I gathered was empirical, self-thought.
3. We are losing more money on "wasted" computation than we realize! And I am talking here about silly mistakes and unnecessary computations we do in Go, nothing too advanced. E.g. allocating at some point [591MB for fetching ~4MB worth of dataset](https://github.com/thanos-io/thanos/pull/3046#issuecomment-679249733) - imagine how it looks on a scale with TBs of data. And this number is from the project that measures efficiency, not to mention others that never did any real benchmarking.

Given the evident knowledge gap in the community, lack of extensive resources on this topic (and the important rule that you learn the most when you teach others!), I decided to take this jump and write a book with O'Reilly help. Based on our experience and learnings, I hope that this work will allow readers to improve their skills in writing high-quality Go code that is also faster and cheaper to run. And who knows, maybe systems written in Go that we all use in the community will get more effective contributions that also increase the reliability and efficiency of those projects? (:

## What's Next?

The book is planned to be released near the end of Q1 2022. No delays are yet planned, but you know how it works. 😉 Both me and Frederic have full (if not over-full) time jobs and lots of open source commitments, but we are on track so far. Stay Tuned!

We are slowly building a small community around the book and Go efficiency topics in the new `Efficient Go Community` Discord server. Here is the link to [join us](https://discord.com/invite/7g5MJqFcQG). This is the perfect spot to give feedback to us about the early access content, propose topics to write about and ask questions around Go and performance!

You can also follow [@bwplotka](https://twitter.com/bwplotka) and [@fredbrancz](https://twitter.com/fredbrancz) on Twitter. If you want, get notified about updates, promotions, opportunities to contribute and events! My DMs and email are also open if you have any suggestions for the content already!
