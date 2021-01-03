---
authors:
- name: "Bartek Płotka"
date: 2021-01-01
linktitle: "Configuring Software in 2021 is Still Broken"
type:
- post 
- posts
title: "Configuring Software in 2021 is Still Broken"
weight: 1
categories:
- open-source
- configuration
images:
- "/og-images/2020.gif"
featuredImage: "/og-images/2020.gif"
---

## Executing and (re) Configuring Software

<IN PROGRESS>

Many conventions were established for performing remote procedure calls, especially over the network: OpenAPI (Swagger), gRPC, REST, GraphQL, etc. However, before those systems and applications are running and accepting calls, the underlying software has to be **configured** (static configuration) and **executed** on computers (server, vm, container, IoT, laptop, PC etc). More advanced software can be also **reconfigured** without restarting (dynamic configuration).

Every software has to be started and configured in some way, and even these days it's not straightforward:

![Configuration Ecosystem](https://docs.google.com/drawings/d/e/2PACX-1vSgaiMbd13bLn0lzsvxRk76ljyQf7EPWSjXP85JoVQEVb9TdvTarN0ScvPmsqB5FsCbiuWEqL5xfNw4/pub?w=1440&h=1080)

### Users, Operators, Developers

In 2021 when a user (let's call them `Configurators`) want to start a newly discovered application, they might have many questions:

* How to tell what convention application is using?
* How to make sure the convention is actually well implemented?
* How to discover all options?
* Are strings are escaped?
* What are the defaults?
* What are the hidden flags?
* Is the configuration file dynamically reloaded?
* What YAML structure this application expects?
* How to track flag changes over time?

Some of those are can be answered if application is nice enough to implement some more popular Linux conventions like `--help` and `man`. But most the time it's a try an error process.

But that's not all. These days we tend to automate everything. And it's the true way to scale out and achieve more things. GitOps, Operators, Configuration as a code, containers and Kubernetes emerged. Those tools share the same goal: **They configure and run software**. So machines are important consumers (executors as well).

And all above user questions still exist and it's even more painful to overcome, because **machines are quite bad at reading `--help` (no standard for that), `man` files and human written documentation.** (at least in 2021).

Last, but least, it's extremely hard for a developer or maintainer of any application (executable creator):

* What convention to choose from?
* How to answer above user's questions without writing a book or two?
* Can I finally start focus on core functionality of software without wasting time on reimplementing configuration layer for each OS and distros?
* How to verify if configuration layer works?
* How to design configuration file structure that will be understandable? What language to use?

### Idea: OpenConfig

With https://xkcd.com/927/ in mind, what if we **every software** would, on top of exiting CLI and configuration conventions always support another convention that allows your executable to be invoked and configured in standard way?

![OpenConfig](https://docs.google.com/drawings/d/e/2PACX-1vSI4Z7dP3TfnoFFAohwCATtC_JOcc1TPgGgaPrkcs2SdNjLPfwMUAQa2D5DmlbG_sI_s7HqJzv4VrAM/pub?w=1440&h=1080)

