---
authors:
- name: "Bartek Płotka"
date: 2020-01-31
linktitle: "How to Become an OSS Project Maintainer, Survive.. And Have Fun on The Way!"
type:
- post 
- posts
title: "How to Become an OSS Project Maintainer, Survive.. And Have Fun on The Way!"
weight: 1
categories:
- community
---

In this post I would like to share what, in my honest opinion, a "perfect" maintainer of the open source software should be.
Yes, no one ever will be perfect: We all have limited time, we all make mistakes and have some skills to learn.
However there is nothing bad in defining what we should aim for. (: 

Some quick  glossary before that:

* Maintainer:  Person responsible for the open source project development and community. The one having full write access to the software repository. Sometimes called "committer".
* Contributor: Person, usually user of the project (not necessarily developer) who contributes to the project in any form: docs and code fixes, reporting issues, helping others on forums, issues, slack.
* PR: Pull request: Code changeset, proposing certain change to the project.

That's why I am presenting you here the top 7 of practices to do to become a better maintainer:

TODO: List those section I desribe below once done.

It's important to note that you don't have to be maintainer at all to follow those suggestions.
If you want to just became maintainer of some project, you contribute to, by following those advices you will increase
your chances significantly. Chances that someone will trust you to do a solid project maintenance. Or let me put me it this way: 
if you do the opposite, it's certain that no one will want you as the maintainer. (:

All of those I learned by practice while maintaining [Thanos](https://thanos.io), [Prometheus](https://prometheus.io) and other projects.
However mainly I found those by *observing* amazing examples of good maintainer behaviour, as well as seeing anti-patterns.
I am personally far from being perfect, but I try to follow those good patterns and improve everyday.

Last but not the least the following practices are purely soft skills related. I won't touch in this post how you should design your system, 
or write your code. Also let's assume you use GitHub Issues for bugs/feature requests and PRs for proposing changes.

## Be polite and friendly

I hope I don't need to say this, but no one will ever consider you as a good maintainer if you are not inclusive, approachable and polite.
No one says you have to be everywhere, talk to all users, always smile, and like everyone. No. But you have to be professional.
Either respond politely or don't respond at all. Never go into meaningless argues especially on Twitter (: Report sketchy interactions,
escalate but never fight back with trolls or aggressive people. 

Also don't sell you open source project too pushy or in spammy way. It's easy to say "product X is shit, and our software is better".
But in this way you are in some way offending others while maybe they just have different trade-offs, different use cases etc.
If you think your software is better, then keep doing good work, and see how users will adapt and like your product. They will do that when they see factual benefits, not just dry words.

Never swear. Be tolerant. Use "her" instead of "his" more often. Avoid offensive jokes. Accept that contributors makes mistakes,
sometimes are frustrated ("Merge it please how difficult is?? it's one click of the button for you!!!!"). 
Users sometimes don't understand your project. Some of them don't see complexities and they miss what maintenance burden means.
However some contributors actually give amazing ideas and golden improvements so that's a trade-off of having the project in open source. (:

Try to be nice if you are suggesting changes on a PR. Try to explain reasoning, especially if someone is new to the community.

For example instead of saying: 
 
```
"Lol, that's wrong, it should be `NiceName()` not `ThatWrongName()`"
```

Maybe you could say:

```
"This is great overall, thanks! But I think we can still improve name of this method. The reason is that [consistency, more verbose, less complex, style guide linked here, etc]"
```

Important: Never ever compromise quality of the project just to be `friendly`! But be nice where you can e.g in communication in issues, PRs, slack or Twitter.
This also includes private communication, because nothing leaves internat these days. (: 

## Improve your English

This is must have. Language details matters. Making basic grammar mistakes is not just ugly, they can seriously obfuscate the communication. It makes the person you wrote to (in e.g issue):

* In the best case: Waste their time trying to understand exactly what you meant, asking following up questions etc
* Worse: They will just ignore your message, not respond at all.
* The worst: They will do totally opposite action to what you just recommend, waste time even more and get frustrated.

This is really important: As a maintainer you need to save time. So, it's quite funny but to overall save time you have to sometimes spend bit more time on your messaging:

* Always write full sentences. 
* Avoid "this" "those" "that" words. 
* Always explain in as much details as you can. 
* Link to other communication as well.
* Install [Grammarly](https://www.grammarly.com/) web plugin.
* Look in Google translate if you are unsure about some wording.
* Avoid abbreviations and shortenings. For example this sentence makes sense but it's probably unreadable for most of you: `"FTW we should avoid CRD in PO if used on OCP as part of CS and GSoC"` (: 
* Avoid saying "never" or "always". See why here (:

All those relates to project public communication but also to documentation, flag descriptions, code comments etc.

I agree that it is brutal and unfair, especially for non native speakers like me.
However you have to learn some tiny details of English to be more effective as the maintainer or, more effective as a contributor who might be maintainer some day.

##  Review issues and code carefully; Be strict

We are all busy. Sometimes I am so tired and when there is some common issue, and someone reports new one that looks similar
my brain automatically assumes it's a duplicate. Only to then see that I did not read carefully, was mistaken and that the reason is different.
So yes: Don't rush out too much, and **read things carefully**.

With PR: As maintainers we need to be extra careful. Software these days is complex. Go language improves readability enormously
(I would say it's the most simple and readable programming language), but still some software I work on ([Thanos](https://thanos.io))
is a distributed system that involves concurrency, tricky optimizations like [mmaping](todo) and [bespoke binary formats](todo).
This means that every details might matter. And yes, we guarded against mistakes with unit/integration/e2e tests, cross-building tests and static analysis on every commit,
but the coverage is always to low and it's easy to miss stuff. And every mistake cost: sometimes just time, sometimes reputation, sometimes actual money when you have major incident (e.g data loss, unavailability)

I might be perfectionist, but IMO it's really bad if the maintainer approve the PR with very visible mistakes, showing clearly that she/he did not even scroll it until the end ): 
There might be different reasons. Maybe maintainer was too tired, maybe simply did not see that mistake. Maybe she/he wanted to be nice and not block a contributions?
Maybe author did amazing PRs before so they trust the author, so "why would I need to review carefully?" There could be sometimes evemore selfish reasoning: 
They yolo approved just to show they are active, even though they don't have time to maintain project full time. 

This is not only related to maintainers. As external contributor you can also review pull request!
In fact e.g in our review process policy, a contributor code review (if done by contributor we trust it knows a codebase)
can be enough to merge some less impactfull PRs. I think this is great because it allows contributor to do reviews in a safe environment,
with other maintainers to guide them if some comment is not particularly correct. It's also a very good sign that contributor is ready to become maintainer!

So! For every PR, as the maintainer, please:

* Never ever approve the PR if you are not really sure if it makes sense OR if you don't have time to review it properly.
It is totally fine to postptone review totally or review only part of it and say that you can't review all right now.
That's critical and please take it seriously. Green is a green: PR is approved (green) if you would be ok to deploy this in production. This is at least what we follow in Thanos project.
* Don't trust anyone. Everyone does mistakes. Some more often, some less but still. Ask questions, challenge the code.
* Review your own code. Trust me this works! if you change mindset into reviewer one and try to look through your diff before others, you can save some time ((: 
* Follow the suggestions I had in previous sections: be friendly and use proper English.

With all of this, let's not go to extreme. It's probably fine if some variable name is not perfect or if some comment is missing, but I think you get my point. (: 

They say there are two types of developers. Some are happy to merge buggy, YOLO code because you can always improve it later and you can move quickly.
MVP is done immediately, demo works in no time. But then what? Who will refactor the code? Who will make it consistent? Who will "productionise" it? And when? Answer is: probably no one, never (:
That's why I am in other groups of developers: Those who aim for quality vs short term velocity. Design first vs quick MVP. We do that while maintaining both Thanos and Prometheus projects.
And I suggest that as a honest best practice for long term projects like that. (: 

Remember: Some contributors will literally hate you because you are strict on details and refuse to add the feature they implemented.
But in fact more people will hate you if the project will be causing incidents, because of YOLO code, unnecessary complexity or unmaintainable features. (:

## Be Proactive, Intelligently Lazy.

TBD

(Announce achievements, Talk; Automate, small PRs! Don't just ping people. Tweet, presentations, delegate, teach, linters, docs instead of answering questions.)

## Want more help?  Give back, help others.

TBD

(e.g be fair about bugs, find org that helps, reuse code, contribute to other projects, be friendly to other projects, help others to learn Go, linux, k8s, presenting)

## Stay Healthy; Have Fun!

TBD

(Don't be afraid of mistakes, don't overwork, it's fine to have delayed response, you can't satisfy everyone, avoid negative persons)

## Summary 

TBD 

It's my first non-coding, non system design blog post so.. please give me feedback! If you don't agree with something or I missed important detail..
let me know (: And I wish you pleasant project maintainance ♥️. 
  