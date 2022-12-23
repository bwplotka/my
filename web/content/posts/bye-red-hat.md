---
title: "Last Day @ Red Hat..."
date: "2022-12-23"
categories:
- career
featuredImage: "/og-images/red-hat1.jpg"
---

> "Something ends," [Geralt](https://witcher.fandom.com/wiki/Geralt_of_Rivia) said with difficulty. "Something ends, [Dandelion](https://witcher.fandom.com/wiki/Dandelion)."
>
> "Not at all," the poet shot back seriously. "Something begins."
>
> -- Andrzej Sapkowski; [Unofficial translation](https://witcher.fandom.com/wiki/Something_Ends,_Something_Begins_(unofficial_translation)#VIII) of Polish book "Witcher; Coś się Kończy, Coś się Zaczyna (2000)".

Happy Holidays Everyone!

I know some of you might be preparing for Christmas, well-deserved PTO, time with family and the New Year! This is amazing, and please make sure your recharge before 2023 & take it easy.

For me, the New Year will mean more changes than just `year++`. I decided to leave my job at Red Hat and pursue new challenges under a different employer (announced in a few weeks). Today is my last working day at Red Hat. I am going for a few weeks of PTO to rest, clean up some stuff and prepare for the next chapter in my career.

In this post, I would love to share a bit of retrospective, acknowledgements and future plans for myself and open source activities I participate in.

## The Past

I [joined Red Hat in September 2019](https://twitter.com/bwplotka/status/1169251183640399873). It might be "only" 3.25 years, but honestly, it was one of the best work times I had in my life. What a journey!

I started my adventure in an ex-CoreOS team where we led important transformations (inside Red Hat and in open source) towards pragmatic observability - starting with monitoring and debugging using the Prometheus ecosystem (Prometheus Operator, Thanos, Alertmanager, Grafana, mixins). It was truly amazing to feel [the CoreOS](https://www.ycombinator.com/companies/coreos) vibes. Although CoreOS got just acquired by Red Hat, I had the opportunity to work with CoreOS colleagues (my manager was from CoreOS, too), visit the CoreOS office in Berlin multiple times and finally learn the way the work and think about open source, innovations, Kubernetes, pragmatic SRE and managed services.

![CoreOS office](/images/blog/coreos.png)

Together, we made a fantastic effort to create software and educate the community and internal teams in Red Hat on those things. As a result, I feel we positively impacted many teams, especially around getting into new things like cloud-native technologies, observability, SRE and managed services.

Among other things, we scaled the internal analytics setup to support a few thousand OpenShift clusters. We also transformed this setup into a bigger, multi-tenant observability managed service, with the analytic portion being one tenant out of many. We managed to convince management, implement and (run!) a global, managed service for all observability signals, fully supported by open source projects like Prometheus, Thanos, Loki and Tempo. If that feels interesting to you, check out [Observatorium](https://observatorium.io/) project that has some starting pieces you could reuse right now.

With that and other monitoring products, our team started to grow as a key dependency in Red Hat, literally saving millions $$$ in internal monitoring costs. We became one of the first teams to start developer on-call rotations and high-quality SRE standards (kudos to the Red Hat SRE teams for all the help to make that happen!). We began to collaborate between observability signals, aligning metrics with logging and tracing (and a bit of continuous profiling). We are innovating in key aspects of observability like correlations, UI, multi-cluster solutions, federation and tenancy.

Finally, we spent a lot of effort on upstream CNCF projects that are helping Red Hat as well as thousands of other organizations. We helped to drive the Prometheus project that keeps growing in terms of metrics and standards adoption, with all major players having managed service for Prometheus nowadays or/and using PromQL. The Thanos project has seen massive growth and has become the de-facto solution for scaling Prometheus metrics in the CNCF space with a healthy and active community. Together with other Prometheus and Thanos maintainers, we actively mentored in the CNCF space (I counted 26 mentees 😱), resulting in exceptional hires in Red Hat and beyond. Lastly, we build strong friendships in open source, despite different employers, backgrounds and opinions.

![DevSummit with Prometheus Team in Red Hat Office](/images/blog/devsummit.png)

I really wanted to thank everybody I worked with, in the past 3+ years, for all the hard work we did together! ❤️

I definitely learned a lot. I met an extreme amount of passionate people on the way. I spoke at 30+ conferences and events. I co-organized events. I was able to travel & work remotely from half of the countries in Europe. I had the opportunity to work as a developer, SRE, team/tech lead and, through the last 1.5 years, an architect. Some learnings allowed me to write my ["Efficient Go" book](/book).

While I am leaving Red Hat, I would honestly recommend Red Hat to anybody passionate about software development and site reliability engineering (ideally a mix of it!), especially if you care about true open-source as we do! Given the current work stream, observability parts are constantly growing, as they are key to Red Hat products and cost savings.

## What's Next

I love my work, but I also love doing ambitious (and sometimes silly) things, so it's time for me to try something different. When it's too comfortable, we tend to be lazy, which hinders our growth. It might be only a little bit different from the outside, though, as I will still be around the open source space, especially the Prometheus ecosystem 🤗. I will still be helping in maintaining Prometheus, Thanos, and smaller Go libraries like prometheus/client_golang and others included [here](/about#open-source).

The plans for 2023 are extremely exciting, and I can't wait to share some of those with you! Today I can share one: I will have two full-time jobs - one called "fatherhood" at a company called "life". My baby girl, Amelia, is due in March! ❤️

![Our cat already approves the baby equipment!](/images/blog/cat-a.png)

I will share more information about the "second" employer at the beginning of 2023 (:

In terms of conferences I plan to attend [FOSDEM](https://fosdem.org/2023/) (Brussels ~4-5th February) and [State Of Open](https://stateofopencon.com/) ([OpenUK](https://openuk.uk/) conference; London 7-8th February). There will be some book giveaways and book-signing activities as well!

## Summary

I honestly questioned if I should share information about my change. It feels like bragging about a new job in a time of layoffs, an unsure economy, an ongoing epidemic (flu these days) and wars.

On the other hand, we should celebrate more often the changes, moments of accomplishments and past hard work with other humans. You might also have questions or worries about my future involvement with open source and why I left Red Hat. Hope I satisfied your curiosity, at least to some degree!

Merry Christmas and Happy New Year! Have fun, and see you in open-source as usual! 
