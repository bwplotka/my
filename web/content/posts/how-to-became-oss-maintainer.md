---
authors:
- name: "Bartek Płotka"
date: 2020-02-02
linktitle: "How to Become an OSS Project Maintainer, Survive.. And Have Fun on The Way!"
type:
- post 
- posts
title: "How to Become an OSS Project Maintainer, Survive.. And Have Fun on The Way!"
weight: 1
categories:
- opensource
---

In this post I would like to share what, in my honest opinion, a **"perfect"** maintainer of the open source software should be.
Yes, no one ever will be perfect: We all have limited time, we all make mistakes and have some skills to learn.
However there is nothing bad in defining what we should aim for. (: 

Some quick glossary I use in this (too long) post:

* *Maintainer*: Person responsible for the open source project development and community. The one having full write access to the software repository. Sometimes called "committer".
* *Contributor*: Person, usually user of the project (not necessarily developer) who contributes to the project in any form:
docs and code fixes, reporting issues, helping others on forums, issues, slack.
* *PR/Pull request*: Code changeset, proposing certain change to the project.

### Top 7 of practices to do to become a better maintainer

TODO: List those section I describe below once done.

### You don't have to be maintainer at all to follow those suggestions.

If you want to just became maintainer of some project, you contribute to, by following those advices you will increase
your chances significantly. Chances that someone will trust you to do a solid project maintenance. Or let me put me it this way: 
if you do the opposite, it's certain that no one will want you as the maintainer. (:

All of those I learned by practice while maintaining [Thanos](https://thanos.io), [Prometheus](https://prometheus.io) and other projects.
However mainly **I found those by *observing* amazing examples of good maintainer behaviour**, as well as seeing anti-patterns.
I am personally far from being perfect, but I try to follow those good patterns and improve everyday.

Last but not the least the following practices are purely soft skills related. I won't touch in this post how you should design your system, 
or write your code. In fact probably most of your work as maintainer will be communication with the people.

Also let's assume you use GitHub Issues for bugs/feature requests and PRs for proposing changes.

So.. Let's go!

## Be polite and friendly

I hope I don't need to say this, but no one will ever consider you as a good maintainer if you are not inclusive, approachable and polite.
No one says you have to be everywhere, talk to everyone, always smile and like everyone. No. But you have to be professional.

**Never swear.** Be tolerant. Use "her" instead of "his" more often. Avoid offensive jokes. Accept that contributors makes mistakes.

### Either respond politely or don't respond at all. 

Never go into meaningless argues especially on Twitter (: Report sketchy interactions,
escalate but never fight back with trolls or aggressive people. 

### Don't try to sell your open source project too hard, in pushy way
 
It's easy to say `"This other product X is shit, and our software is better"`. However, in this way you are in some way offending
others while maybe they might just have different trade-offs or different use cases etc.
If you think your software is better, then keep up the good work, and see how users will adapt and enjoy using your product.
They will do that when they see factual benefits, not just dry words.

### Saying "No" without offending others

This one of most difficult skills you need to learn as a maintainer. Some feature was proposed, code was written and it
totally does not fit the project's goal and vision. Contributor gets frustrated: 

```
"Merge it please how difficult is?? it's one click of the button for you!!!!" 
```

This happens, you need to learn how to be patient, always try to respond clearly explaining why decision is to reject.
Try to propose an alternative that will work for the users, usually there is some other project that helps, or tooling, or API 
that you contribute can integrate with your project instead! [See example "No" in Thanos project](https://github.com/thanos-io/thanos/issues/2014#issuecomment-579824888)

Users sometimes don't understand your project. Some of them don't see complexities and they miss what maintenance burden means.
However some contributors actually give amazing ideas and golden improvements so that's a trade-off of having the project in open source. (:

Show friendliness and gratefulness for all the contributions, even for the code that was not eventually merged. Still
contributor spend time and effort. Probably she/he learned on the way, so nothing is a total waste!

**Important: Never ever compromise quality of the project just to be `friendly`!**

### Try to be nice if you are suggesting changes on a PR. 

This is maybe obvious, but when you review dozens PRs a day, you can lose patience. 
 
Still, always try to explain reasoning, especially if someone is new to the community.

For example instead of saying: 

```
`"Lol, that's wrong, it should be ThisNiceName() not ThatWrongName()"
```

Maybe you could say:
 
```
"This is great overall, thanks! But I think we can still improve name of this method.
The reason is that [consistency, more verbose, less complex, style guide linked here, etc]"
```

It's really worth it! Contributors will love to contribute because they are learning, and they feel more supported.

### Be proactive and clear

You can't escape awkward situations. Sometimes you can have two contributors yelling each other in the PR in their own
language that someone has right to implement certain feature. Another time you want to quickly want to fix issue, while there is already
not perfect PR waiting for contributor to rebase. Or maybe you have contributor who tries to "triage" issues by just
commenting on every issue `ping @bwplotka` several times (like I am not getting spam in inbox already...).

Try to consider other peoples feeling. What really helps in ALL those cases is to actually ask the contributor to join Slack
and discuss the matter directly. in 99% the situation gets resolved, because person feels supported, she or he knows you care
and you can fully explain why and what etc. Also you can provide feedback to the person **directly** in private channel.
Sometimes people just don't know they are rude or doing something wrong. 
It's really ok to say the truth and be honest about the problem, as long as it is delivered in nice positive way (!).

### Have fun!

Open Source is really fun place. If you spent your work time at forums, GitHub issues and working with the community, it's 
always worth to fill this place with positive energy! Laugh, jokes, funny situations, memes, emojis. Everything is allowed!
It helps to maintain healthy atmosphere and break some ice on the way! Your slack forum or Github Issues don't need to be
always a sad place full of reported OOMs or race conditions! (: 

As an example, I recently was amused by contributors from Russia that clearly where having some extra (%%%) help when
making [this PR's comment](https://github.com/thanos-io/thanos/pull/1789#issuecomment-559025685). =D Met them at [FOSDEM] and they are obviously nice guys in real life as well. (: 

**Overall:** be nice where you can e.g in communication in issues, PRs, slack or Twitter.
This also includes private communication, because nothing leaves the internet these days. (:  

## Improve your English

This is must-have. Language details matters. Making basic grammar mistakes is not just ugly, they can seriously obfuscate
the communication. It makes the person you write to (in e.g issue):

* In the best case: Waste their time trying to understand exactly what you mean, asking following up questions etc
* Worse: They will just ignore your message, not respond at all.
* The worst: They will do totally opposite action to what you just recommend, waste time even more and get frustrated.

### As a maintainer you need to save time. 

It's quite funny but to save time overall you have to sometimes spend bit more time on your messaging:

* Always write full sentences. 
* Avoid "this" "those" "that" words. 
* Always explain in as much details as you can. 
* Link to other communication as well.
* Install [Grammarly](https://www.grammarly.com/) web plugin.
* Look in Google translate if you are unsure about some wording.
* Avoid abbreviations and shortenings. For example this sentence makes sense but it's probably unreadable for most of you: 
  
  ```
    "FTW we should avoid CRD in PO if used on OCP as part of CS and GSoC, LMK"
  ```
   
* Avoid saying "never" or "always". See why here (:

All those relates to project public communication (slack, forums, PRs) but also to documentation, flag descriptions, code comments etc.

I agree that it is brutal and unfair, especially for non-native speakers like me.

However you have to learn some tiny details of English to be more effective as the maintainer or, more effective as a
contributor who might be maintainer some day.

## Review issues and code carefully; Be strict

We are all busy. There are times when I am so tired and someone reports an issue that looks similar to a certain common issue,
my brain automatically assumes it's a duplicate. Only then I see that I did not read it carefully, and I was mistaken and
the real reason was different.

So yes: Don't rush out too much, and **read things carefully**.

### When reviewing PR: As maintainers we need to be extra careful
 
Software these days can be complex. Go language improves readability enormously, I would even say it's the most simple
and readable programming language out there. However, still some software I work on ([Thanos](https://thanos.io))
is at the end a distributed system that involves concurrency, tricky optimizations like [mmaping](https://github.com/thanos-io/thanos/blob/56a1fb6c084f11638f6f7b6532adc07dd05824b6/pkg/block/indexheader/binary_reader.go#L457)
and [bespoke binary formats](https://github.com/thanos-io/thanos/blob/56a1fb6c084f11638f6f7b6532adc07dd05824b6/docs/components/store.md#format-version-1).

This means that every detail might matter. And yes, we guarded against mistakes with unit/integration/e2e tests, cross-building
tests and static analysis each commit, but the coverage is always to low and it's easy to miss stuff.
 
And every mistake cost: sometimes just time, sometimes reputation, sometimes actual money when you (or any of users of your project)
have major incident (e.g data loss, unavailability).

### It is really bad if the maintainer approve the PR with very visible mistakes

To me it means that she/he did not even scroll the proposed change until the end ): 
There might be different of course reasons behind mistake. Maybe maintainer was too tired, maybe simply did not see that
bug. Maybe she/he wanted to be nice and not block a contributions? Maybe the author did amazing PRs before so maintainer trusted the
author, so `"why would I need to review it carefully?"`. Unfortunately, there can be sometimes even more selfish reasoning: 
They approved just to show they are active, even though they don't have time to maintain project full time. 

### As external contributor you can also review pull request!

In fact e.g according to our review process policy, a contributor's code review (if done by the contributor whom we trust and
she/he knows a codebase) can be enough to merge some less impactful PRs. I think this is great because it allows contributor
to do reviews in a safe environment, with other maintainers to guide them and step in if some comment is not particularly
correct. It's also a very good sign that contributor is ready to become maintainer!

### Rules for every PR I try to follow

As the maintainer, please:

* Never ever approve the PR if you are not really sure if it makes sense OR if you don't have enough time to review it properly.
It is totally fine to postpone a review or review only part of the PR and say that you can't review all right now.
That's really critical and please take it seriously. Green is a green: PR is approved (green) if you would be ok to deploy this in production.
This is at least what we follow in Thanos project.
* Don't trust anyone. Everyone does mistakes. Some more often, some less but still. Ask questions, challenge the code.
* Review your own code. Trust me this works! If you change your mindset into reviewer's one and try to look through
your own diff before others, you can save some time for everyone ((: 
* Follow the suggestions I had in previous sections: be friendly and use proper English.

### Don't go to extremes.
 
It's probably fine if some variable name is not perfect or if some comment is missing, but I think you get my point. (: 

### There are two types of maintainers

In one group, maintainers are more happy to merge maybe not yet ready code, because you can always improve it later and
you can move quickly. MVP is done in no time, demo is ready. But then what? Who will refactor the code? Who will make it
consistent? Who will "productionise" it? And when? Answer is: **Probably no one, never** (:

That's why I am more in favor of the other group of people: Those who aim for quality vs short term velocity. Design
first vs quick MVP. We do that while maintaining both Thanos and Prometheus projects. I strongly believe that is a
best practice for long term projects like that. (: 

Remember: **Some contributors will literally hate you because you are strict on details and refuse to add the feature they
implemented. But in fact more people will hate you if the project will be causing incidents, because of YOLO code,
unnecessary complexity or unmaintainable features. (:**

## Be Proactive, Intelligently Lazy.

TBD, Public dev channel.

(Announce achievements, Talk; Automate, small PRs! Don't just ping people. Tweet, presentations, delegate, teach, linters, docs instead of answering questions.)

## Want more help?  Give back, help others.

TBD

(e.g be fair about bugs, find org that helps, reuse code, contribute to other projects, be friendly to other projects, help others to learn Go, linux, k8s, presenting)

## Stay Healthy; Have Fun!

TBD

Boundaries, work life balance

(Don't be afraid of mistakes, don't overwork, it's fine to have delayed response, you can't satisfy everyone, avoid negative persons)

## Summary 

TBD 

It's my first non-coding, non system design blog post so.. please give me feedback! If you don't agree with something or I missed important detail..
let me know (: And I wish you pleasant project maintainance ♥️. 
  