---
authors:
- name: "Bartek Płotka"
date: 2020-04-06
linktitle: How Thanos would program in Go?
type:
- post 
- posts
title: How Thanos would program in Go?
weight: 1
categories:
- go
featuredImage: "/images/blog/flagarize/ide-header.png"
---

**TL;DR: Recently we introduced extended Go Style Guide for [the Thanos project](http://thanos.io/), a high scale open-source distributed metric system where, with our large community, we take extra attention and care for the code quality.**

##  Go + distributed systems = ❤️

Modern, scalable backends systems can be incredibly complex. Despite our efforts with other Maintainers, to not add too many features, APIs or inconsistencies to our projects like Prometheus or Thanos; even with extra work on unblocking users with efficient integrations and extensible API, we still have to maintain quite a large codebase And the facts, that our systems are in some way stateful (databases!).. and distributed.. and used by thousands of small and big companies (with often varying requirements) are not helping. (:

Undoubtedly [Go](https://golang.org/) suites this job really well. While achieving low-level solid performance is not trivial, it's still close to C++. What's more important, the maintenance and development velocity is extremely fast in comparison to other languages. With Go it's also quite easy to write reliable software. 

Most of those language benefits can be attributed to the main charectistic of Go: Readability. The language itself has many tools to (sometimes automatically) ensure consistency and simplicity: Only ~one "idiomatic" way of doing things (e.g. error handling, concurrency, encoding), the only one formatting... and no generics. (: All of those idiomatic patterns are well 
described in [Effective Go](https://golang.org/doc/effective_go.html
) and [CodeReviewComments](https://github.com/golang/go/wiki/CodeReviewComments), which was written almost at the beginning of the Go language!

## So why one would need another style guide?

Official, mentioned guides are amazing, quite strict and cover a large spectrum of patterns, but there were done for the whole language, for ALL users. This means there is a little bit of freedom here and there. Those guides had to be appliable for all sorts of software: backend distributed systems, low-level IoT software with linked C code, GFX applications, CLI tools, in the browser or even [as a configuration template](https://github.com/bwplotka/mimic).

That's why with the Thanos Team we decided to share [the official Thanos Style Guide](). It takes all the things from official Effective Go and CodeReviewComments and that's on top of them, plenty of bit more strict rules. This allowed us to produce with the community even more readable and efficient Go on projects we maintain like Thanos, Prometheus, Prometheus-Operator and more.

In this blog post, I will try to quickly go through **more** interesting improvements to the official guides with some rationals (: 

You can find the full-length official Thanos guide [here].

## Thanos Coding Style Guide


## Summary
