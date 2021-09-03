---
weight: 1
date: 2020-09-03
linktitle: "Announcing Our Book with O'Reilly: Efficient Go!"
title: "Announcing Our Book with O'Reilly: Efficient Go!"
date: 2021-09-03
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

> TL;DR: I am super excited to announce an exact topic of our book we write together with O'Reilly publisher. "Efficient Go" will consist of 10 chapters, including one from amazing [Frederic Branczyk](https://twitter.com/fredbrancz)! The book is planned to be released near the end of Q1 2022. Stay Tuned! Join our Discord Community using this [link](https://discord.gg/3rCttps74F) or follow [@bwplotka](https://twitter.com/bwplotka) on Twitter if you want to get notified about updates, promotions, opportunities to contribute and events!

Almost exactly seven months ago, I announced that I will be writing a book with the publisher I have always admired, [O'Reilly](https://twitter.com/OReillyMedia). Since this time, the book development has started, a significant part was delivered, the topic has been clarified, and motivation is even stronger! Yet still, lots of work is ahead of us.

I decided it is now a great time to reveal more details on what I write about and with whom. So in this post, you will learn about book topics, motivation and what YOU can personally gain by following this work!

## What This Book is About?

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

## Who is Helping?

There are plenty of people who already contributed to our book's existing content, and I can't thank them enough for the past and future help! Also, thanks to the open-source communities I participate in, I was grateful to meet many amazing people, willing to sacrifice, often their free time, for this work.

In terms of content, I ([Bartek Płotka](https://www.bwplotka.dev/about/)) am the primary author of this book with nine chapters planned from my side. But I'm not alone! I am super happy to have [Frederic Branczyk](https://twitter.com/fredbrancz) joining "Efficient Go" with the chapter dedicated to [Profiling](https://www.polarsignals.com/blog/posts/2021/08/03/diy-pprof-profiles-using-go/)--a must-to-know technique when it comes to finding the efficiency bottlenecks quickly in your application. Frederic is my friend, experienced Go developer and Prometheus maintainer. As a CEO and founder of the [PolarSignals](https://www.polarsignals.com/), a start-up focused on bringing next level, continuous profiling to open source and as a service, there might be no better expert in this space! I am super excited about this contribution. I hope you are too!

I would also like to thank here [Michael Hausenblas](https://twitter.com/mhausenblas) and [Stefan Schimanski](https://twitter.com/the_sttts) who were super helpful in the early stages, things like choosing the publisher and process of writing book. Kudos to my employer, too, Red Hat, who supports me in writing my book in my free time.

## My Honest Motivation Behind The "Efficient Go"

TBD

## What's Next?

The book is planned to be released near the end of Q1 2022. No delays are yet planned, but you know how it works. 😉 Both me and Frederic have full (if not over-full) time jobs and lots of open source commitments, but we are on track so far. Stay Tuned!

We are slowly building a small community around the book and Go efficiency topics in the new `Efficient Go Community` Discord server. Here is the link to [join us](https://discord.gg/3rCttps74F). This is the perfect spot to give feedback to us about the early access content, propose topics to write about and ask questions around Go and performance!

You can also follow [@bwplotka](https://twitter.com/bwplotka) and [@fredbrancz](https://twitter.com/fredbrancz) on Twitter. If you want, get notified about updates, promotions, opportunities to contribute and events! My DMs and email are also open if you have any suggestions for the content already!
