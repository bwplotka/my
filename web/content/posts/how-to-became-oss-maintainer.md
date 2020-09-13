---
authors:
- name: "Bartek Płotka"
date: 2020-02-11
linktitle: "How to Become an Amazing OSS Project Maintainer, Survive, And Have Fun on The Way!"
type:
- post 
- posts
title: "How to Become an Amazing OSS Project Maintainer, Survive, And Have Fun on The Way!"
weight: 1
categories:
- open-source
- observability
---

In this post, I would like to share what, in my honest opinion, a **"perfect"** maintainer of an open source software should do.
Yes, no one ever will be perfect: we all have limited time, we all make mistakes and have some skills to learn.
**However, there is nothing bad in defining what we should aim for.** (: 

Some quick glossary for this (long) post:

* **Maintainer**: Person responsible for the open source project development and community. The one having full write access to the software repository. Sometimes called "committer".
* **Contributor**: Person, usually user of the project (not necessarily developer) who contributes to the project in any form:
docs and code fixes, reporting issues, helping others on forums, issues, Slack or IRC.
* **Pull request (PR)**: Code changeset, a proposal of a certain change to the project that should be reviewed.

## Top 6 of practices for becoming a better maintainer:

1. [Be Polite and Friendly.](#1-be-polite-and-friendly)
2. [Improve Your English.](#2-improve-your-english)
3. [Review Issues and Code Carefully. Be Strict.](#3-review-issues-and-code-carefully-be-strict)
4. [Be Proactive and Intelligently Lazy.](#4-be-proactive-and-intelligently-lazy)
5. [Want More help? Give Back, Help Others.](#5-want-more-help-give-back-help-others) 
6. [Stay Healthy. Have Fun!](#6-stay-healthy-have-fun)

### NOTE: You don't have to be maintainer to follow those suggestions.

If you want to just become maintainer of some project you contribute to, by following those pieces of advice you might increase
your chances. Chances that someone will trust you to do a solid project maintenance. Or let me put it this way: 
**if you do the opposite, most likely, no one will want you as the maintainer.** (:

### I am far from being perfect, but I try to follow those rules. 

My first [open source contribution was in 2015 to the Apache Mesos](https://github.com/apache/mesos/commits?author=bwplotka).
Since then I fell in love with open source work and started to learn the things I am sharing in this post by *observing*
examples of good maintainers' behavior as well as seeing some anti-patterns. 
On top of this, I learned a lot by practice while co-maintaining [Thanos](https://thanos.io), [Prometheus](https://prometheus.io)
and [other projects](../../about/#open-source-projects). And don't get me wrong: **I am personally far from being perfect, but I try to improve every day.**

Last but not least the following practices are purely related to **soft skills**. I won't touch in this post how you
should design your system, what technologies you should use or how to write your code. **If you did not already notice,
probably most of your work as the maintainer will be communication with humans.** 🤗

## 1. Be Polite and Friendly.

I hope I don't need to say this, but no one will ever consider you as a good maintainer if you are not: *inclusive, approachable and polite.*
No one says you have to talk to everyone, always smile and like everyone. No. But you have to be professional.
**Never swear.** Be tolerant. Use gender-neutral pronouns (e.g. "they"), don't assume anyone's gender if it's not necessary.
Never make offensive jokes. **Accept that everyone makes mistakes.**

### Either respond politely or don't respond at all. 

Never go into meaningless debates especially on Twitter. (: Report sketchy interactions, escalate but never fight back with
trolls or rude people. 

### Don't try to sell your open source project too hard, in a pushy way.
 
It's always easy to say `"This other product X is shit, and our software is better"`. However, by doing so, you are in some way offending
others when potentially they might just have different use cases, made different trade-offs, etc.
If you think your software is better, then keep up the good work, and see how users will adapt and enjoy using your product.
They will do that when they see factual benefits, not just dry words.

### Saying "No" without offending others.

This one of the most difficult skills you need to learn as a maintainer. Some feature was proposed, code was written and it
does not fit the project's goal and vision. Then the contributor gets frustrated: 

```
"Merge it, please! How difficult is that? It's just one click of the button for you!!!!"
```

This happens a lot and you need to learn how to be patient. Always try to respond by explaining **why the team decided to reject.**
Try to propose an alternative that will work for the user. Usually, there is some other project that helps, tooling, or API 
that your contributor can integrate with your project instead! [See example "No" in Thanos project.](https://github.com/thanos-io/thanos/issues/2014#issuecomment-579824888)

Users sometimes don't understand your project. Some of them don't see complexities. They miss what maintenance burden means.
On the other hand, some contributors give amazing ideas and golden improvements so that's a trade-off of having the project in open source. (:
**Important: Never compromise the quality of the project just to be `friendly`!**

### Always say "thank you".

Show friendliness and gratefulness for all the contributions, even for the code that ultimately was not merged. Still,
the contributor spent time and effort. Probably they learned on the way, so nothing is a total waste!

### Try to be nice if you are suggesting changes on a PR. 

This is maybe obvious, but when you review dozens of PRs a day, you can lose patience. Still, always try to explain the reasoning, especially if someone is new to the community.
For example instead of saying: 

```
"OMG, that's bad, it should be ThisNiceName() not ThatWrongName()..."
```

Maybe you could say:
 
```
"This is great overall, thanks! But I think we can still improve the name of this method.
The reason is that [consistency, more verbose, less complex, style guide linked here, etc]"
```

It's really worth it! Contributors will love to contribute because they are **learning**, and they feel more supported.
They will understand the reasons and rules behind all the small programming decisions, so they will be capable to produce
better PRs in future as well as potentially help you in review process!

### Be fair and clear. Use direct communication.

Awkward situations are unavoidable. Sometimes you can have two contributors yelling at each other in the PR about who has
the right to implement a certain feature. Another time you want to quickly fix the issue, while there is already
a PR by some contributor, waiting for a rebase. Or maybe you have a contributor who tries to "triage" issues by just
commenting on every issue `ping @bwplotka` several times (like I am not getting notifications in my inbox already...).

**Try to consider other people's feelings.** What helps in **ALL** of those cases is to **ask the contributor to join Slack (or IRC, etc)
and discuss the matter *directly*.** In 99% of cases, the situation gets resolved because you show that you care. The person feels supported,
and you can fully explain why and what, etc. Sometimes people just don't know that they are rude or doing something wrong.
 
**It's ok to say the truth and be honest about the problem, as long as it is delivered in a nice, positive way!**

## 2. Improve Your English.

This is a must-have. Language details matter. Making basic grammar mistakes is not just ugly, they can seriously obfuscate
the communication. It makes the person you write to (in e.g. an issue):

* In the best case: Waste their time as they will try to understand exactly what you mean, ask follow-up questions, etc.
* Worse: They will just ignore your message, not respond at all as they are confused.
* The worst: They will do the opposite of what you have just recommended, waste even more time, and get frustrated.

### It saves time. 

It's quite funny but to save time overall you have to sometimes spend a bit of time in the first place. For example, on your messaging:

* Write full sentences. 
* Avoid unclear back references with `this`, `that`, `these`, `those` words.
* Try to explain as many details as you can. 
* Link to other communication.
* Install the [Grammarly](https://www.grammarly.com/) web plugin.
* Look in Google translate if you are unsure about some wording.
* Avoid abbreviations and shortenings. For example, this sentence makes sense but it's probably a bit cryptic: 
  
  ```
    "FTW should we introduce ASAP CRDs in PO if used on OCP by SWE from CS and GSoC? LMK"
  ```
   
* Avoid saying ["never" or "always"](https://twitter.com/pracucci/status/1221397473555550209).

This relates to the project public communication (Slack, forums, PRs) but also to documentation, flag descriptions, code comments, etc.
And I agree that it is brutal and unfair, especially for non-native speakers like me. **However, it's really beneficial to learn some deeper
details of English to be more effective as the maintainer** or more effective as a contributor who might become a maintainer someday.

## 3. Review Issues and Code Carefully. Be Strict.

We are all busy. However, don't rush too much, and **read things carefully**.

### When reviewing a PR; as maintainers, we need to be extra careful.
 
Software these days can be complex. [The Go language encourages readable code.](https://talks.golang.org/2014/readability.slide)
However, still, some software I work on (e.g. [Thanos](https://thanos.io)) is in the end a distributed system that involves concurrency,
tricky optimizations like [mmap'ing](https://github.com/thanos-io/thanos/blob/56a1fb6c084f11638f6f7b6532adc07dd05824b6/pkg/block/indexheader/binary_reader.go#L457)
and [bespoke binary formats](https://github.com/thanos-io/thanos/blob/56a1fb6c084f11638f6f7b6532adc07dd05824b6/docs/components/store.md#format-version-1).

This means that every detail might matter. And yes, we guard against mistakes with unit / integration / e2e tests, cross-building
tests and [static analysis on each commit](https://github.com/thanos-io/thanos/blob/25f5b0b9290fa1620647f00dd8df954380efc530/Makefile#L292),
but the coverage is always too low and it's possible to miss stuff.
 
And every mistake has a cost: sometimes just time, sometimes reputation, sometimes **actual money** when you (or any of users of your project)
have a major incident e.g. data loss, unavailability.

### It is really bad if the maintainer approves the PR with very visible mistakes.

To me it means that they did not even scroll through the proposed change. There might be different reasons behind
such a mistake. Maybe the maintainer was too tired or simply did not see that bug. Maybe they wanted to be nice and not
block contributions? Maybe the author did amazing PRs before so the maintainer trusted the author? Unfortunately,
sometimes **the reason is more selfish**: they approved just to show they are active, even though they don't have time
to maintain the project full time. Don't be like this. It is pretty obvious!

### As the external contributor you can also review pull requests!

For example, the Thanos review process encourages code reviews by contributors. For a less impactful PR, the review from a
trusted contributor that knows the codebase can be enough to merge the PR. I think this is great because it allows a contributor
to do reviews in a safe environment, with other maintainers to guide them and step in if some comment is not particularly
correct. It's also a very good sign that the contributor is ready to become the maintainer!

### Rules for every PR I try to follow.

🚨 As the maintainer, please: 🚨

* Never approve the PR if you are not sure if it makes sense OR if you don't have enough time to review it properly.
It is totally fine to postpone or review only a part of the PR and say that you can't review everything right now.
**That's critical and please take it seriously**: green is green. Only approve a PR if you would be ok to deploy it to production.
This is at least what we follow in the Thanos project.
* Don't trust anyone. Everyone makes mistakes. Ask questions, challenge the code. Anyone means also yourself! Don't merge 
your own PRs without review. (:
* Make use of [the scout rule](https://www.oreilly.com/library/view/97-things-every/9780596809515/ch08.html), but very carefully. Ask the author
to fix places around the areas they are contributing to unless they are totally new or it's a difficult or an invasive change.
* Follow the suggestions I had in previous sections: be friendly and use proper English.

### Controversial: Refuse to review and merge huge (1k+ lines of code) PRs.

Only a few are capable to review such an amount of code in detail. Additionally, it's really difficult to find 3h of the
continuous focus to review such a huge PR properly. It all ends with delayed reviews, merging not fully reviewed code and increasing chances of
unnecessary complexity or bugs. **Avoid big PRs by splitting them and chaining into smaller PRs**. Alternative is to maintain functional commits,
but it tends to be harder and non-obvious to work with for both author and reviewer. 

One exception: replace-like (e.g. `sed`, `go mod vendor`, `goimports`) changes across many packages are acceptable, as long as the author
also presents the script / command that was used to perform rename. **Just make sure you don't mix changes made by the script with the manual ones!**

### Strict vs fast.

In my opinion, there are two types of maintainers. In one group, maintainers are happier to merge potentially not yet ready code,
because you can always improve it later and you can move quickly. MVP is done in no time, the demo is ready. But then what?
Who will refactor the code? Who will make it consistent? Who will "productionise" it? And when? The answer is: **Probably no one, never** (:

That's why I am more in favor of the other group of people: Those who aim for **quality** vs short term velocity. **Design
first** vs quick MVP. We aim for quality and design-first while maintaining both Thanos and Prometheus projects. I strongly
believe that this is the best practice for long term projects.

Remember: Some contributors will not like you because you are strict on details and refuse to add the feature they
implemented. **But more people will hate you if the project will be causing incidents, because of [YOLO code](https://jaxenter.com/yolo-driven-development-methodology-113469.html),
unnecessary complexity or unmaintainable features. (:**

### Don't go to extremes.
 
It's probably fine if some variable name is not perfect or if some comment is missing. Nothing will be perfect. 
It is even sometimes fine to defer some work by inserting a `// TODO(@author):` or filling a GitHub issue. *"Strict"*
also does not mean that someone else's PR has to be exactly how you would implement it. **Be open-minded and happy for
a professional discussion.** People think in different ways. Just make sure the PR works, is readable and meets the style guide.
It does not mean you have to be always right! (: 

## 4. Be Proactive and Intelligently Lazy.

There are certain rules that you can stick to if you want to be a more efficient maintainer and simply have more time to focus on what matters.

### Prefer asynchronous communication but use synchronous as well.

First of all, define the project's means of communication. Keeping GitHub issues for feature requests, bug reports and feedback makes
sense. It is asynchronous, easily searchable and easy to follow. Prefer that. But these days it might be not enough. First of all,
potential users are sometimes too shy to file an issue with maybe basic questions due to e.g. a missing piece of the documentation.
Setting some synchronous channels like Slack (we use that in the Thanos project) or [IRC](https://xkcd.com/1782/) (Prometheus) is exactly for this purpose.
**The mix of synchronous and asynchronous communications helps to build trust and good relationships within the community and between contributors and maintainers.**

Additionally, if you want to resolve a problem, quickly discuss some matter or design, it is much better to schedule some discussion on Slack,
than having just a slow comment-by-comment conversation on a GitHub issue or on a PR, which might take weeks. With such more direct communication
**users and contributors gain more trust in the project.** At some point, you will find that the community helps each other
to answer questions and last but not least: you can find new friends! (:     

### Keep discussions open and inclusive.

All non-sensitive, non-security related communication can be made in public. In my opinion, it even *should* because **"open source" contains the word "open" for a reason**.
The reason is that openness is extremely powerful. When you have all discussions, even those of the maintainer team, in public,
everyone can learn, get the context, get easily involved, motivated, and up to date. Last but not least, you can avoid
confusions like [this.](https://github.com/prometheus/prometheus/pull/6760#issuecomment-583733400) 
**At the end: everyone saves tons of time!**

Additionally, anything you put on the internet, even privately, **can leak anyway** so always be kind and prepared to defend or support your past words! (:

### Repetitive work? Automate. 

You would be surprised at how innovative people are in order to *avoid work*. All small repetitions can quickly add up to
[weeks of time](https://xkcd.com/1205/) during your whole lifetime, so they matter. In the Thanos project we try to optimize everything:

* We were spending too much time during a review process to ensure proper commentaries 🕵️ e.g. sentence have to be started with capital letters
and finished with a period. We were super strict about it. But sometimes instead of focusing on the essence of the PR,
I was spending time commenting on wrong comments. That's why we created [CI script](https://github.com/thanos-io/thanos/blob/55cb8ca38b3539381dc6a781e637df15c694e50a/scripts/build-check-comments.sh#L85)
that verifies this for us in the CI pipeline. Similar with: [wrong whitespaces detection](https://github.com/thanos-io/thanos/blob/25f5b0b9290fa1620647f00dd8df954380efc530/Makefile#L176),
[copyright file headers detection](https://github.com/thanos-io/thanos/blob/55cb8ca38b3539381dc6a781e637df15c694e50a/scripts/copyright/copyright.go#L23)
and [linting](https://github.com/thanos-io/thanos/blob/25f5b0b9290fa1620647f00dd8df954380efc530/Makefile#L292) our code heavily.
**All of this to make sure maintainers do not have to!**
* We autogenerate our documentation from flags and [configuration](https://github.com/thanos-io/thanos/blob/55cb8ca38b3539381dc6a781e637df15c694e50a/scripts/cfggen/main.go#L41).
This saves the effort of maintaining documentation, it is harder for it to get obsolete. We check if links work with the amazing [liche tool.](https://github.com/thanos-io/thanos/blob/25f5b0b9290fa1620647f00dd8df954380efc530/Makefile#L185)
* Every commit triggers a [build of our website](https://github.com/thanos-io/thanos/blob/72bac9e9e184fc747b245de7efe73987343b03b2/netlify.toml#L2) hosted in the same repository, including preparing a handy preview thanks to [netlify.](https://www.netlify.com/)
* We wrote a Go `testing` package extension that [allows to run benchmarks as tests](https://github.com/thanos-io/thanos/blob/master/pkg/testutil/testorbench.go#L10).
* We use [leaktest](https://github.com/thanos-io/thanos/blob/56a1fb6c084f11638f6f7b6532adc07dd05824b6/pkg/query/api/v1_test.go#L51)
to make sure we don't leak go routines (and as a result: memory).

Does some repetition frustrate you? Handle it with automation! Here is one such [recent frustration.](https://github.com/thanos-io/thanos/issues/2102)

### Try to answer someone else's question... with a new section in your documentation!

This is easy to say, but not as easy to incorporate. However, you will notice that if you follow this, it will reduce
the number of repeated questions and other contributors will be able to respond to each other in e.g. Slack channel.

In fact, I wrote this blog post because someone asked for feedback on how they can become a maintainer! (: 

Of course, it escalated a bit...

### Handle bug reports effectively.

Bug reports can be upsetting and stressful. But they will not if you will learn how to consistently handle them!

**Never ignore bug reports**. First, understand how critical it is. Data loss should be treated differently than too spammy log line. 
Ask for more details and guide the user to debug on their own. Combine duplicates under a single issue which will allow others
to follow on the bug with ease. Is there any mitigation (e.g revert, manual action)?

If it's a known bug and you know how to fix it: mention it! Even if no one works on it yet, **still mention that you have some
idea how to fix it and explain how**. It's 1000x better than just leaving the bug without a response. Users and contributors
will feel much more supported. Explanation also helps someone else to jump in and implement a fix. Adding `help wanted` label to the issue helps as well.  

### Do you want users to give feedback? Make the project accessible.

Having extensive documentation is key. But there are more ways to encourage your users to grab the latest build without fear and
deploy your code early! One way of doing it is [building a docker image on each merge to master](https://github.com/thanos-io/thanos/blob/master/.circleci/config.yml#L59)
(e.g. with tag `master-<date>-<sha>`).

### Admit your mistakes and fix them.

We all make mistakes. Maintainers do them as well e.g. with project's design decisions. Always be open for improvements, even if it means
saying sorry, and **removing a powerful feature** that is causing problems and confusion. For example [we decided to remove our fancy gossip
functionality to simplify Thanos.](https://thanos.io/proposals/201809_gossip-removal.md/) 

Another example for one of our initial mistakes was pushing our docker images as `latest` tag. [**Never use or push the `latest` tag**](https://vsupalov.com/docker-latest-tag/). Period.
It's confusing and magic. Avoid magic.

**Overall**: be open to changes, even though it means to admit that you were wrong. That is fine because you learned!

## 5. Want more help? Give back, help others.

There is an old Chinese saying: `The rose's in their hand, the flavor in mine` (learned this thanks to our Chinese contributor ♥️).
This is again, in my opinion, a very important and maybe surprising truth: **How to build community? By helping the community out!**

You can't be selfish. You created and maintain the open source project in the first place, so you are already helping out the people.
But at some point, you feel stressed, exhausted, alone or helpless. This is where the community helps enormously.
You want more users, because a (tiny) percentage of those users actually will give back and help out. Some of them will
become maintainers next to you **or even friends.**

So how to achieve that? *Just ask around, say that you need help...?* **Well, not really...**

### Contribute. Reuse.

The answer is easy: help others. Instead of building a project from scratch out of nowhere **build it on the shoulders of giants**.
First of all, make sure someone needs it except you. Thanks to extending another project, you already have data about the main pain points.
Secondly, you have a helpful community to start with. Thirdly, you can (and you probably should) reuse some pieces of the code from
another open source projects.

Reuse has many potential advantages:

* You [LEARN!](https://twitter.com/bwplotka/status/1216693249055887360)
* You immediately hook into the ecosystem (e.g. by sharing an API). This means you can reuse the same integrations and tools!
* Multiple parties are maintaining the same components. A reused piece of code has more users, thus it is more tested and mature. Your project is then safer as a result.
* You help multiple projects, so you will get help from them if needed! (e.g. review something on your project, help with design questions, etc.)

This is what I and [Fabian](https://github.com/fabxc) did with the [Thanos](https://thanos.io/) project: we reused exactly
the same storage format as Prometheus, as well as many other components that we directly import from the Prometheus codebase.
At some point, because I was maintaining those dependencies as they were critical to the Thanos project, I became the
maintainer of Prometheus itself! (: In the end, I am helping with much more than just parts that Thanos relates to.
**I give out more because, in my opinion, kindness always returns in double!**

### Mentor. Enable others.

Everyone needs experienced, motivated and highly skilled people to work with. But people don't get born like this.
In open source you meet a variety of contributors. Sometimes it will be a bad-ass ex-Googler, ex-Uber who wants to help and
gives you some amazing ideas, but sometimes, you will work with people who just started their journey with programming, distributed
systems or infrastructure.

There will be moments where you would do a change 10x faster than getting back-and-forth on the same PR with the newbie. You 
will get angry that you are gaining almost nothing and instead you are a free mentor; a Git, Linux, Bash, English teacher or a Security, Kubernetes guide.

**But don't be frustrated, because you actually gain something: Potentially skilled contributor, a happy human that is very likely to start
amazing contributions and to become another maintainer someday!**

So... be patient and enable others if you can. Additionally, be proactive and participate in programs like [Community Bridge](https://communitybridge.org/)
or [Google Summer of Code](https://summerofcode.withgoogle.com/). These allow students to quickly ramp up into your
project (and get paid on the way). This is especially amazing as it allows underrepresented groups to be mentored and helped by maintainers
and maybe someday improve the diversity of your project's team or at your work.

### State project expectations from the beginning.

One way to avoid later frustration, stress or just fuss is to make sure the project **has explicitly stated its goals.**
Tell users what to expect from the project. E.g. Prometheus and Thanos are not designed to collect events. That's why it will be
never optimized for such high cardinality data.

Is something not done yet? Is it in the experimental stage? Is it not tested properly? **Explicitly mention it.**
You don't want some huge customers to report that they lost millions because something in your project lost data. Obviously, it's their
legal responsibility, not yours – it's an open source project after all. But you want to make sure that users know what are the best practices and where
to be careful.

### Consider donating your project to a trusted Open Source organization.

This has many benefits. The most important one is that you are not alone, but also (in theory) the project is independent. 
At some point when the project will be big enough (think: Prometheus), there will be many parties that want to influence it, because there is money there.

Organizations like [Apache.org](https://www.apache.org/), [the Linux Foundation](https://www.linuxfoundation.org/) and [the Cloud Native Computing Foundation (CNCF)](https://www.cncf.io/)
help to maintain independence in terms of decision making. They also help with operational functions like organizing conferences and meetups,
3rd party paid resources (e.g. cloud resources for testing), swag, security audits and more. We donated [Thanos to the CNCF](https://improbable.io/blog/improbable-donates-thanos-to-cloud-native-computing-foundation)
and we are very happy with that decision.

### Stay organized

One way to get more productive is to start from your own personal organizational skills. For that, I really recommend the book 
[Getting Things Done by David Allen](https://www.audible.co.uk/pd/Getting-Things-Done-Audiobook/B01B6WT3JY).
 
Spoiler alert! Focus on clearing your mind. If you have a quick <3min task, just do it. For longer one try to note what's the next step
and save it in some trusted place (Google Keep, notebook). Visit this place every morning. This will allow your mind to relax,
be innovative and focused on what is now!

## 6. Stay Healthy; Have Fun!

This is the last one but also the most important rule you will read here. **Don't overwork.** If you are tired or maintaining
does not make you happy anymore, then first try to rest (no computer allowed!). If you need a longer break, leave the project gracefully.
Do a clean handover, rather than just disappearing or pretending to still be a maintainer (just to keep that badge of honor).
If that does not help, then just quit and find another thing to focus on.

**Open source is an opportunity to find best friends, have lots of fun and an amazing job. However, it is also a place of endless requests, bug reports, and questions.**

* There will be users that want help NOW, HERE because something they misconfigured is on fire.
* There will be people from different cultures, spamming you directly via email about their requests.
* There will be hard decisions to make and all of them might be somehow wrong (that's called trade-off...)

And on top of that, you might be just a part-time maintainer like most of us are. Everyone has a job on top of it with more or less
time dedicated to open source. **For example, at [Red Hat](https://redhat.com/) we design, develop and we are even on-call for our internal monitoring platform, where
we use some of the products we maintain.** Moreover, probably no one knows about that. Everyone thinks it's your only focus and blame you for slow project movement... 
Which comes to another point: 

### Don't be afraid to make mistakes; no one actually blames you personally!

Naturally, your imagination will trick you that if someone files a bug report or comment about your code it will definitely mean
they *hate you* and *your work*. Everyone has some insecurities, so it's totally fine to have such an impression.
**What helps? Growing a healthy maintainers team.** Trust other contributors and give them a chance. What you win is a feeling of shared
responsibility.

Additionally, it helps if you would **assume by default that everyone is positive and professional**. 99% of people I met so far in the open source world
are nice, friendly and positive. They will not blame you for mistakes unless you do something malicious on purpose.
Everyone makes mistakes, so it's normal. Don't be shy and allow yourself to be more open! 

There is one way of learning this in no time: **making mistakes**. What do you think: How many times did I say something on the internet that was stupid?
How many typos I did? How many English grammar mistakes? `Millions of them`.

One time I said on a public, recorded Prometheus Community Meeting that:
 
```
"I am Prometheus maintainer and I became just recently a Thanos maintainer"
```

...and the truth was the opposite: I co-created Thanos, and just joined Prometheus team back then.
While I felt super shitty and embarrassed about this, my whole team was laughing. When I look at it now... it did not matter (:

I think it's a trade-off again and I can trade my *external perfect image of a perfect person*
**for extremely meaningful conversations, things I learned on the way, relations I gained, public speaking that made the community more diverse and bigger, etc.**
In open source, you probably should say `goodbye` to your perfect "external no-mistake image".

If you wont't accept this, you might not be happy in maintaining a public project. It might be simply unhealthy, so keep that in mind.

### Open source project maintenance is not a sprint, it is a marathon.

This is what I heard once from a friend when I was overworking, and it is very true. Short periods of extreme programming, deciding about the project,
after-hours issue triaging and working during the weekend might look fine... **but you won't be able to sustain that for a long time.**

Set boundaries and maintain a healthy work-life balance. You don't have to respond to issues immediately. Allow others to
investigate issue first for learning purposes, and only guide them through. Always take time for a high-quality rest.
A rested and a clear mind will solve problems 100x faster. Don't sacrifice weekends, sleep 8 hours, do sports.

**Depression and burnout is pretty serious stuff ⚠️. At the moment of writing, I'm 27 years old and I already (seriously) burnt out twice in my
career.** I definitely don't recommend that! I burnt-out because of too high expectations towards myself, overworking, ambitions, etc.

### Have fun!

After all, open Source is a fun place. If you spend some of your work or free time at forums, GitHub issues and working with the community, **it's
always worth to fill this place with positive energy!** Laugh, jokes, funny situations, memes, emojis. Everything is allowed!
It helps to maintain a healthy atmosphere and break some ice on the way! Your Slack forum or GitHub issues don't need to be
always just a sad place full of reported OOMs or race conditions! (: 

As an example, I was recently amused by contributors from Russia that clearly where having some extra *%%%* help while
making [this PR](https://github.com/thanos-io/thanos/pull/1789#issuecomment-559025685) 😂. I have met them at the [FOSDEM](https://fosdem.org/)
the other day and they are nice people in real life as well. (: 

## Summary 

This guide is something I am aiming for when interacting with the community and maintaining open source projects.
I definitely failed many times to follow these rules, especially around the staying-healthy part. (: But I feel like these items
can guide you **to achieve happiness and improve the open source world!** We can sum these rules into 3 main points:

### Treat others like you would like to be treated.

Be friendly, because you would like for someone to be friendly to you. Don't sell your project in everyone's users' faces,
as you also would not like to be spammed on your own project's forum. **Help others, teach them how to program, use Linux, Git or
make presentations as you probably also had help in the past (and you will need in future).**

### Do you want to become a maintainer? Behave like a maintainer!

Literally, almost everything maintainers do, any contributor can do. You can respond to Slack questions and GitHub issues.
You can review code. You can guide other users and contributors. You can tweet, speak at conferences about the project.
Try to mimic the good patterns from other maintainers and do the hard work. **You don't need write permissions to make decisions
and act like a maintainer of the project.**

### Be innovative; challenge processes; optimize! 

Always question processes. Are they good enough? Can this repetitive task be automated? We had many innovative ideas
just because we were frustrated that we waste time. **Try to optimize for quality and time saving.** This will give you more time for pleasure. (:

### Last message...

Starting a new project and becoming a maintainer will not guarantee you a community from day 1. It is a very long journey and hard work.
Usually not a work of a single person. What I would suggest is to join another project first. Grow and learn. Choose your passion and go!
Check `good first item`, or `help wanted` labels for GitHub issues, join community calls, Slack channels.

And... that's it! I hope you will find all of this helpful.

### I wish you pleasant and fruitful project maintenance ♥️.

PS: Thanks to @beorn7, @brancz, @daixiang0, @juliusv, @LiliC, @kakkoyun, @mjudeikis, @pstibrany, @roidelapluie for help
in reviewing this long post 💓. I believe it's a nice base of good maintainership practices, people can reference to!

PS.2: *It's my first non-coding, non-system design blog post so... please give me feedback! If you don't agree with something
or I missed an important detail, let me know via [Github Issue](https://github.com/bwplotka/my/issues) or DM! (:* 
