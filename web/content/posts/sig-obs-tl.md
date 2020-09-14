---
authors:
- name: "Bartek Płotka"
date: 2020-09-14
linktitle: Becoming Tech Lead for the CNCF SIG Observability! 
type:
- post 
- posts
title: 📈 Becoming Tech Lead for the CNCF SIG Observability!
weight: 1
categories:
- open-source
- observability
images:
 - "/og-images/santorini.jpg"
featuredImage: "/og-images/santorini.jpg"
---

**TL;DR: In March 2020, we established the official [CNCF's](https://cncf.io) Special Interest Group (SIG) for [Observability](https://github.com/cncf/sig-observability).
Last week, the [TOC](https://github.com/cncf/toc) vote for the first Tech Lead for this SIG was closed, and results [were published](https://lists.cncf.io/g/cncf-toc/topic/76717430#5272). 
I am proud to announce that I have been elected! 🤩** 

In this blog post, I would like to briefly explain what is the idea behind SIGs, what our "newly" created SIG for Observability is for.
Last but not the least, I will share why I decided to help and what tech lead role in the SIG context means. 

## Special Interest Groups for the Cloud Native Computing Foundation

Around April 2019, the CNCF [approved the initiative called Special Interest Groups (SIGs)](https://github.com/quinton-hoole/toc/blob/06ffaaa9a288b081b012f8c508ede5f1e45cf900/sigs/cncf-sigs.md). 
The main idea behind SIGs is to ***scale contributions***. What does it mean? Well, CNCF is growing rapidly. The current number of projects
donated or related to the [CNCF](https://landscape.cncf.io/) is just enormous. 

![CNCF Landscape: How to manage this open source machine?](/images/blog/sig-obs-tl/landscape.png)

The popularity of the CNCF universe is undoubtedly high. The last pre-COVID CNCF conference was in San Diego in 2019, and it was one of the largest. It had nearly 10k physical (!) attendees.
Looking at [the latest stats](https://all.devstats.cncf.io/d/1/activity-repository-groups?panelId=4&fullscreen&orgId=1&var-period=h&var-repogroups=All), the activity in all CNCF's Projects on just GitHub (code, reviews, comments) every hour is 500 on average with peaks up to 1k. And that does not
even count activity in thousands of open source dependencies, tools and projects related to the main repositories, and all non-GitHub activity
like participating or organizing events (meetups, conferences), mentoring, teaching, etc.

![Peak of 1k hourly activities on main GitHub repos? That gives a single, meaningful human contribution event every 3.5999928 seconds!](/images/blog/sig-obs-tl/cncfactivity.png)

Given the number of projects and activities, before SIGs, there was a major slowdown in the various decisions making, innovations, and organizational activities.
Simply put, the TOC model did not scale. Having a dozen experienced and amazing people from different companies that
control CNCF space is amazing, but there are just too many topics. There has to be some method of
delegating some duties and efforts to further people that are passionate in one of many "cloud" areas, specific
to their domain expertise. The similar problem was already solved by the Kubernetes project itself with like "divide & conquer"
in a form of creating [domain-specific interest groups](https://github.com/kubernetes/community/blob/master/sig-list.md). 

> BTW the whole concept isn't new! The first SIG was created in 1961 for the [Association for Computing Machinery (ACM) society](https://en.wikipedia.org/wiki/Special_Interest_Group#Technical_SIGs).

This is how [the various SIGs](https://github.com/cncf/toc/tree/master/sigs#current-sigs) were slowly created on the CNCF side too!
As of September 2020 we have 7 SIGs. Each with some TOC members as the Liaisons: 

| Name | TOC Liaisons |
|------|--------------| 
| [SIG Security](https://github.com/cncf/sig-security) | Liz Rice, Justin Cormack |
| [SIG Storage](https://github.com/cncf/sig-storage) | Xiang Li | 
| [SIG App Delivery](https://github.com/cncf/sig-app-delivery) | Michelle Noorali, Katie Gamanji | 
| [SIG Network](https://github.com/cncf/sig-network) | Matt Klein |
| [SIG Runtime](https://github.com/cncf/sig-runtime) | Brendan Burns, Alena Prokharchyk |
| [SIG Contributor Strategy](https://github.com/cncf/sig-contributor-strategy) | Matt Klein |
| [SIG Observability](https://github.com/cncf/sig-observability) | Jeff Brewer, Brendan Burns |

> Liaison: a person who acts as a link to assist communication or cooperation between people.

Next to the Liaison, SIG consists of Chairs, Tech Leads, and Members. (Fun fact: Each SIG can also define its own
[specific roles](https://github.com/quinton-hoole/toc/blob/06ffaaa9a288b081b012f8c508ede5f1e45cf900/sigs/cncf-sigs.md#other-named-roles))

### General SIG Objectives

Each of the SIGs in the CNCF has, in general, the following objectives. The objectives you can find on the TOC repo
are self-explanatory:

* Strengthen the project ecosystem to meet the needs of end users and project contributors.
* Identify gaps in the CNCF project portfolio. Find and attract projects to fill these gaps.
* Educate and inform users with unbiased, effective, and practically useful information.
* Focus attention & resources on helping foster project maturity, systematically across CNCF projects.
* Clarify the relationship between projects, CNCF project staff, and community volunteers.
* Engage more communities and create an on-ramp to effective TOC contribution & recognition.
* Reduce some project workload on TOC while retaining executive control & tonal integrity with this elected body.
* Avoid creating a platform for politics between vendors.

## Observability SIG

Around February 2020, most of the CNCF projects had each corresponding SIG created. This means they had better
support and for any potential graduations, annual reviews, or initiatives. The number of topics from Observability
related projects piled up, so it was about the time, [Matt Young](https://twitter.com/halcyondude) started conversations about potential Observability SIG:

![First interaction](/images/blog/sig-obs-tl/matt-start.png)

Long story short, thanks to amazing people listed [here](https://github.com/cncf/sig-observability/blob/master/observability-charter.md#cncf-sig-observability-charter),
we completed detailed [CNCF SIG Observability Charter](https://github.com/cncf/sig-observability/blob/master/observability-charter.md)
and got approved by the TOC as an official Interest Group. 🤗 

I won't bore you with the details, you can read the full manifest [here](https://github.com/cncf/sig-observability/blob/master/observability-charter.md),
but overall our objectives are exactly the same as provided [above](#general-sig-objectives). The only difference is our specialization for Cloud Native Observability topics
and projects related to observability. For example, those hosted currently under the CNCF umbrella: 

![Project's under the CNCF in different stages](/images/blog/sig-obs-tl/landscape2.png)

For comprehensive read-up and TL;DR of SIG Observability, I really recommend [Richi's](https://twitter.com/twitchih) amazing [post on the CNCF blog](https://www.cncf.io/blog/2020/06/15/interested-in-the-future-of-cloud-native-observability-join-sig-observability/).

### How You Can Reach us?

Everyone is welcome to ask questions / propose topics to talk through! You can do that in many ways:
 
* Join our bi-weekly [SIG Observability Meetings](https://docs.google.com/document/d/1_QoF-njScSuGFI3Ge5zu-G8SbL6scQ8AzT1hq57bRoQ/edit)! Just add an agenda
item to the doc. 
* If you like async communication more add an issue on our [`cncf/sig-observability` GitHub repo](https://github.com/cncf/sig-observability).
* Write email to `cncf-sig-observability@lists.cncf.io` (subscribe [here](https://lists.cncf.io/g/cncf-sig-observability))
* Join us on the CNCF Slack [`#sig-observability`](https://slack.cncf.io/) 

## Why I Proposed to do (Another) Technical Leadership in my ~Free Time.

Let's be honest, similar to other roles (TOC Members, SIG Chairs, Members, Contributors), being a SIG Tech Lead
is just voluntary, free work. So why would you do that, given other amazing things you could do? (For example:
Resting during the weekend on Santorini, Greece instead of writing this blog post. Don't do this 🙃)

* I think the main reason is that there is just a strong need for work in this area. Someone has to offload TOC members and the CNCF itself in their duties. And 
observability is arguably one of the most important, tricky, and costly element of every web application (in some cases more expensive than monitored applications itself!)
* Given my experience and passion to observability, infrastructure & open source I thought that if I can help with something let's do it fully! (:
* I have already worked with many CNCF projects, communities, but also some of the staff: the CNCF CTO [Chris](https://twitter.com/cra), Program Manager [Amye](https://twitter.com/amye), our Event Hero [Nanci](https://twitter.com/Microwavables)
developer advocate [Ihor](https://twitter.com/idvoretskyi) and more. The thing is that working with each of those people is incredibly amazing: fruitful, productive and at the end: fun! On top of this,
the CNCF hosts projects I maintain, contribute and use every day ([Kubernetes](https://kubernetes.io), [Thanos](https://thanos.io), [Prometheus](https://prometheus.io) and more).
It feels just so fun and relevant to contribute more in this space, so I am grateful for this opportunity. The people active in the SIG Observability so far are amazing too, you should meet them as well!
After all, it's all about people.
* I have seen a good SIG Tech Lead examples in my life and just got inspired by the value they were adding. Here I would love to give a shout-out to ex-colleague [Frederic](https://twitter.com/fredbrancz), Tech Lead of the [Kubernetes SIG Instrumentation](https://github.com/kubernetes/community/tree/master/sig-instrumentation),
who mentored me a bit and introduced in 2019 to Instrumentation SIG. While I was mostly passive there, I learned a lot from Frederic. Seeing good tech leading skills in SIG contexts, gave me motivation to do similar in
the CNCF space.
* Last but not the least, I am grateful to work at [Red Hat](https://redhat.io) which instead of punishing me for spending bit of my work time on SIG contributions (like 98% close source companies would do),
this company actually highly value contributions like this, giving me room to do technical leadership outside of the Red Hat and core projects we maintain as well! 💪

> Red Hat value, seen with my own eyes & definitely no joke: To be the catalyst in communities of customers, contributors, and partners creating better technology the open source way.

## So... What's the Plan?

![](/images/blog/sig-obs-tl/congrats-to-our-new-tech-lead.jpg)

Don't get me wrong, overall I can have many ideas, but in the end, it's really up to the community and all the SIG members
what we can achieve! (: 

*Technically* SIG Tech Lead duties are: 

* To support projects in the SIG’s area.
* To have the time and ability to perform deep technical dives on projects. Projects may include formal CNCF projects or other projects in the area covered by the SIG.

It's really more about the hard work and the responsibility than any major decision making. And that's actually quite nice as I would love to stay
out of politics as much as possible. (: Instead, let's talk about actions, usability, and the things that we can improve for better... **observability!**

As I mentioned, overall it's all about where the SIG members will focus, however since you are still reading this 😈, I can briefly inject some cool stuff that we can improve
in the CNCF Observability world!

I mentioned most of the things in my [nomination doc here](https://docs.google.com/document/d/194INvrWMRZT9p0VxhlkRa9yXK8a4npdBlDvOetWvPb0/edit#), but let's go quickly
through some of those:

### Supporting Projects

The key responsibility of the SIG Observability is to help the CNCF projects, to provide guidance for any technical decisions and support the areas where they need help.
Additionally, for a project to proceed through different stages (Sandbox, Incubated, Graduated); it has to fulfil a couple of, more or less, strict rules
(see [Due Diligence doc](https://github.com/cncf/toc/blob/master/process/due-diligence-guidelines.md)). Those rules are actually
quite solid, they aim for project growth, fairness, reliability, and open-source values. My role is to review, point out gaps, and help to resolve those.

> **Action Item**: If you are a member / contributor of the CNCF project within SIG Observability OR you have any questions related to observability for any
other open-source project (e.g Kubernetes) [reach us!](#how-you-can-reach-us)

### Connecting Passionated People; Sharing Knowledge Between Projects

Depending on the origins of the projects, the CNCF projects collaborate with each other. Some more, some less. For example, both Cortex, Thanos, and OpenMetrics projects were created by
Prometheus maintainers, thus it's natural we share some code pieces and patterns. Overall we work and communicate with each other a lot! 

This, however, is not always the case between other projects; even though we are all hosted under the CNCF. The truth is, that there is a huge potential
of helping each other much more than what we have now. For example, while maintaining a big open source project like Thanos, there are many things we had to invent or build
from scratch to suit our additional needs,  such as:

* A suite of [static analysis tools and Go style guide](/2020/how-thanos-would-program-in-go/) 
* Auto-generated documentation (recently shaping it out of our bash into [mdox](https://github.com/bwplotka/mdox) tooling).
* Development tooling e.g [bingo](https://github.com/bwplotka/bingo),
* Multi-arch artifact building e.g [promu](http://github.com/prometheus/promu),
* End-to-end test frameworks (we share [an awesome e2e library with Cortex](https://github.com/cortexproject/cortex/tree/master/integration/e2e)),
* A website with versioned documentation, search and blog post space,
* Arrangements and best practices for Mentorship/Internships e.g [Student Office Hours](/2020/thanos-mentoring-office-hours/),
* A solid Open Governance model,
* Various configuration practices and methodologies,
* Plugins,
* And marketing activities (Active Twitter account, Talks),

...and much more! This, sometimes annoying, stuff is vital for the project to be usable, reliable, and easy to start with. So why almost every project
rebuild these tooling and facilities from scratch rather than reuse them? (: It would be nice to get together and learn from each other, especially
when we are part of the same foundation and domain! (:

> **Action Item**: If you are active in a CNCF project and need help, try to check out if a similar problem has already been solved in another 
project! You can use SIG Observability space for this freely, so [reach us!](#how-you-can-reach-us)

### Be Open Minded for Outside World

Another point I want to highlight is that, as the SIG Observability, we are not limited to a few hosted projects only. There are certainly missing pieces```
in cloud-native observability portfolio. Things that we could learn. Projects that already comply, integrate or even are already extremely useful for
the whole observability journey in the CNCF ecosystem but not directly under the CNCF governance. I am looking at you: [Grafana](https://github.com/grafana/grafana),
[Loki](https://github.com/grafana/loki) and [ConProf](https://github.com/conprof/conprof)!

It would be awesome to maintain a good relationship with such projects. Allow even better integration with them, communicate more, and help each other!
 
> **Action Item**: If you feel that some projects or initiatives are extremely useful, however missing in the CNCF Observability portfolio, or something we can learn from, please [reach out to us as well!](#how-you-can-reach-us)

## Summary

![View from Pyrgos village on Santorini island, Greece](/images/blog/sig-obs-tl/santorini2.jpg)

I hope with this blog post, you have learned a bit what this magical `SIG` concept is all about. And how `YOU` can help within the domain you are
passionated about!

Thanks to [all who voted for me](https://lists.cncf.io/g/cncf-toc/topic/76717430#5272) and especially thanks to [Richi](https://twitter.com/twitchih)
for some epic mentoring in this area 💪

See Ya on our [SIG Observability Meetings](#how-you-can-reach-us) 👋

