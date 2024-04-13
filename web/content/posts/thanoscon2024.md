---
title: "ThanosCon Retrospective"
date: "2024-04-14"
categories:
- thanos
- community
- open-source
featuredImage: "/og-images/thanoscon1.jpg"
---

Hello back! 👋🏽 Curious how your last weeks looked like, mine were a bit busy:

* My daughter's 1st birthday, then she started daycare adaption with the weekly spread of stomach flu, scarlet fever and other "collectables". Fun.
* Week of final preparations for KubeCon (~7 talks? plus booth duty, organization duties, an interview and a book signing 🙈), then super active KubeCon in Paris together with ~12 thousand attendees.
* Busy time at work, mostly due to the [post-conference excitement syndrome](https://twitter.com/ArthurSilvaSens/status/1778788133837873429) and [Google Next](https://cloud.withgoogle.com/next) that finished this last week.
* Spring fixing and cleaning (e.g. home, cars, garden, bikes, relationships, our own health 🙃).

Excuses aside, one highlight of the last month was our [first official ThanosCon](https://www.cncf.io/blog/2024/03/13/kubecon-cloudnativecon-europe-co-located-event-deep-dive-thanoscon-europe/) organized by some members of Thanos community and the [CNCF](https://www.cncf.io/).

In this post, I would love to share my experience (and gratitude) around the organization process, finalizing the event idea, proposing it to the CNCF, preparing and executing it! Who knows, maybe this transparency will motivate you to participate, speak, sponsor or perhaps organize conferences like that.

### ThanosCon

Let's go ahead and start with the ThanosCon event summary, so we can compare the preparation effort to the effect. The event was fully streamed and available [on YouTube](https://www.youtube.com/playlist?list=PLj6h78yzYM2M0QzJhgCdGVuEhx8OlXpvX). You can find more photos from the event [here](https://photos.app.goo.gl/VoH6nfTeaDSuz6iP9).

ThanosCon was held as a co-located KubeConEU 2024 half-day on March 19th in Paris. This means to get into the event you had to buy or get (e.g. via sponsoring or speaking at KubeCon or co-located event) the "All-Access pass", which on top of the 3-day KubeCon, got you access to **any** of the 19 co-located events day before. The specificality of being a co-located event is worth noting. There were essentially ~6000 attendees (estimation, [the official report will come](https://www.cncf.io/reports/)) on 19th March that could choose any of those 19 co-located events (up to the room capacity). In theory, this means that in every talk from a single even, you could have a different audience.

ThanosCon was scheduled in the morning part of the day (9:00-13:00) in a convenient room (noise isolation, chairs-to-space ratio, AV setup, huge screen) with a capacity of 150 ppl.

![Colin Douch sharing learnings from running Thanos on an extreme scale in Cloudflare to the full room!](/images/blog/thanoscon/thanoscon3.jpg)

> [Colin Douch](https://twitter.com/sinkingpoint) sharing learnings from running Thanos on an extreme scale in Cloudflare to the full room!

I love how the ThanosCon went. We got a "family" vibe atmosphere with people feeling safe to ask (also difficult) questions during the Q&A and afterwards. I also loved how our event was fully focused on one topic--scaling your metrics, cheaply and reliably with the Thanos project. It feels like it allowed the audience to spend the beginning of their day productively, without many distractions, discussing one aspect deeply, end to end. Everyone learned, especially the Thanos contributors and team how to move the project forward.

### Numbers: Attendees, Talks, Sponsors

We got a full room at the peaks (~150 attendees) with literally the queue outside (which means we could get even more people in). I wished we could get in people at least to stand/sit at the back, but our lovely staff members didn't like that idea (: The average attendance was ~110 through all the talks.

I'm super grateful for the amazing speakers who proposed and executed high-quality talks at this event! We had 24 CFP submissions, which would easily fill the full day. We managed to get 7 talks (9 if you count the opening and intro) on the schedule with some schedule kung-fu. Normally you would have time for 5 full talks in a half-day, but we blended a talk into an opening talk and had one lightning talk. Our schedule looked as follows (talks with the most amount of attendees marked with **⚠️**):

* Intro - Michael Hoffmann, Aiven; Bartłomiej Płotka Google
* 6 Learnings from Building Thanos Project - Bartłomiej Płotka, Google; Fabian Reinartz, Databricks
* **⚠️** Monitoring the World: Scaling Thanos in Dynamic Prometheus Environments - Colin Douch, Cloudflare
* **⚠️** Scaling Thanos at Reddit - Ben Kochie & Trevor Riles, Reddit
* Thanos Project Update - Saswata Mukherjee, Red Hat
* Connecting Thanos to the Outer Rim via Query API - Filip Petkovski, Shopify & Mahmoud Amin, Google
* **⚠️** Multiverse of Thanos: Making Thanos Multi-Tenanted - Jacob Baungård Hansen & Coleen Iona Quadros, Red Hat
* Thanos Receiver Deep Dive - Joel Verezhak, Open Systems
* Closing Remarks - Harshitha Chowdary T, Amazon; Bartłomiej Płotka Google

The speaker diversity across companies was great, but across gender, it was not. We tried hard, but only 22% of talks had a non-male identifying person co-speaking (supposed to be 33%, but last-minute changes due to external reasons occurred). Only 14% if you exclude opening and closing talks.

ThanosCon was exclusively sponsored by the CNCF. Kudos to the CNCF, but not ideal--it's not how this works on KubeCon. The chances of this event happening again without external sponsors are low. We contacted a few Thanos big end-users, but the majority of feedback was "oh it's December, Xmas time, decision makers not responding" or "we already closed the sponsors budgets for this quarter, if only you let us know in advance". If you want to see this event again, help us with some leads/motivate your employer! (: On the bright side this is typical for first-time events and not unique compared to other co-located events on that day as well.

### Everything Starts With the Idea

Generally, it wasn't the first event I co-organized or helped to organize. For example, I was [co-organizing Prometheus London Meetups](https://www.meetup.com/prometheus-london/events/?type=past) before COVID. I was KubeCon (Program Committee) PC in the past, helped with [PromCon](https://promcon.io/), co-organized the two (?) initial Observability Days (previously "Open Observability Day") in [Amsterdam](https://www.youtube.com/playlist?list=PLj6h78yzYM2ORxwcjTn4RLAOQOYjvQ2A3), [Detroit](https://www.youtube.com/playlist?list=PLj6h78yzYM2N60fCRNLBL7ymUHg7fFbDZ), as well as [Prometheus Day](https://events.linuxfoundation.org/prometheus-day-europe/). The experience from organizing with others helped to take the courage to initiate a new CNCF co-located event.

On PromCon in late September 2023 in Berlin, organized by amazing folks from [PolarSignals](https://www.polarsignals.com) (and the CNCF) I started to probe ThanosCon idea among the present members of the Thanos community. It would be useful for you to understand that historically, PromCon was always **a one-track, two-day ultra-focused conference** which everyone enjoyed--the topics were focused, the event small enough to be able to talk to people you know already and meet new ones. To be fair, as the project grows, even PromCon gets to talk about the wider ecosystem and broadening the spectrum of topics--while in the past it was all about using Prometheus binary for metric monitoring and observability, now we talk also about external dashboards, AIOps, OpenTelemetry integrations, and of course "distributed Prometheus" systems like Thanos, Cortex or Mimir, which treats Prometheus mostly as an "agent/collector".

The same happens on the Observability Day, and Prometheus Day events and so on. In each of those events we had one or two Thanos talks, but if you want to focus your brain on deeper Thanos usage, best practices and setups, making connections with the community and sharing your experience, bad luck -- you need to sit down and listen (and switch contexts) about other, potentially unrelated to you systems or observability signals. Don't get me wrong, there is value in huge 10k+ ppl events, with a dozen tracks and a thousand topics, but the proposition is a bit different, you are not there to focus on one e.g. system deeply.

> As a result, fresh after PromCon the Thanos community was curious to check if the potential, small event focused purely on Thanos would make sense. A special event, where we could ensure it is moderated and prepared well, with honest work and without politics.

Turns out there were people who loved the idea, and we created a two-page proposal for the CNCF. In fact, anyone [can propose an event](https://events.linuxfoundation.org/kubecon-cloudnativecon-europe/co-located-events/cncf-hosted-co-located-events-overview/#faq-proposal-process) which then will be evaluated by the CNCF. The premise of the co-located day had some benefits:

* For the first ThanosCon event we could start small with a half-day, which is still 3x of content than a casual meetup.
* The cost of the venue and the staff could be shared with all events on that day.
* We got a morning of the "zero" KubeCon day, so people had still fresh minds and were energetic.
* No one had to travel only for the ThanosCon (and as you know the travel budgets for engineers are extremely low in 2024). There are tons of other reasons why you should join ThanosCon, allowing a more diverse audience.
* CNCF helps a lot with organizing.

The obvious downside is that those with smaller conference/travel budgets, can't buy a ticket just for the ThanosCon and travel for one day, which limits many.

Finally, I had an additional selfish reason for organizing the ThanosCon 🙃. I wanted to create an excuse to spend some time with [Fabian Reinartz](https://twitter.com/fabxc). The last time we truly spent time together was during the Prometheus London meetup in 2018 where we introduced the initial design and implementation of the Thanos project we created in 3 months. ThanosCon was an epic moment to stop and reflect on what we learned while observing Thanos's growth in the open source. If you are interested, you are welcome to watch our 15m talk ["6 Learnings from Building Thanos Project - Bartłomiej Płotka, Google; Fabian Reinartz, Databricks"](https://youtu.be/ur8dDFaNEFg?si=0jYwzumqkI6e4dpF&t=350). Those were honest lessons that I plan to be aware of in my future work too (:

### Preparations

At the end of the day, we got chosen (yay!) by the CNCF. Officially the co-chairs of the event were [Sonia Singla](https://twitter.com/soniasinglas) and me, but in practice we had massive help from other members of the Thanos community and CNCF (more on that in [here](#gratitude)).

We started by gathering [10 people](#gratitude) who would help the Programme Committee around Nov 27th--helping us to select the talks and finalize the schedule. In the meantime, we [wrote a blog post](https://thanos.io/blog/2023-20-11-thanoscon/) started an activity on social media and contacted a few end users for talks and sponsorship.

After the CFP period finished (Dec 3th), from Dec 5th to 13th, the PC spent to reviewing the talks. We got a lot of amazing proposals, and it was pretty difficult to reject the majority of them, but that's how it works. Hope to see most of them at another event!

It wasn't too long until we formed the initial schedule with the team. Amazingly, the schedule changed only slightly afterwards (unfortunately, eventually Sonia couldn't join us in person, next time hopefully 🤗), which meant the initially chosen speakers in December delivered talks as planned in March 💪🏽

There were some minor decisions to make and things to do (e.g. preparing opening and closing talks, choosing MC, reviewing other ppl talks and slides if they want), but generally that's it. The rest of the work was done by the CNCF staff, which took the majority of the work from us.

### Gratitude

This event wouldn't have been possible if not for a group of people joining forces to organize something beautiful. I will try hard to cover most of the humans involved, but if I missed you or your contribution, I'm sorry--let me know about this!

> [Scott Galloway](https://www.profgalloway.com/power/#:~:text=If%20I%E2%80%99m%20generous,agency%20of%20others): "...I do have one skill. I foster a decent amount of loyalty among the people I work with. It’s not a function of character or empathy, only the recognition that nothing wonderful happens when you’re on an island. Simply put, greatness and happiness are in the agency of others."

I would like to start by thanking the wide ThanosCon organizing team for amazing work:
* [Sonia Singla](https://twitter.com/soniasinglas) sad you couldn't make it in person, but you helped remotely massively ❤️
* [Filip Petkovski](https://twitter.com/fpetkovsky) thanks for your intuition and especially amazing work on mentoring others 😉! I know now where this "Staff" is coming from (:
* [Harshitha Chowdary Thota](https://twitter.com/ThotaHarshitha) the last-minute travel and preparations to coordinate ThanosCon in-person, with travel paid only by yourself--super impressive, lots of courage and dedication! Thank you!
* [Matej Gera](https://twitter.com/gmat90) thanks for your dedication during preparations and the schedule finalization.
* [Michael Hoffman](https://github.com/MichaHoffmann) I really learned a lot from your speaking skills, humour and high-disciplined preparation skills!
* [Saswata Mukherjee](https://twitter.com/saswatamcode) words are not enough to express the amount of dedication and work you did under the hood for ThanosCon, plus amazing project updates talk, thanks! As always, inspiring others with passion.

Furthermore, thanks to all members of the Program Committee who reviewed in detail all the proposed talks: [Anaïs Urlichs](https://twitter.com/urlichsanais), [Ben Ye](https://twitter.com/yeya24), [Filip Petkovski](https://twitter.com/fpetkovsky), [Harshitha Chowdary Thota](https://twitter.com/ThotaHarshitha), [Lili Cosic](https://twitter.com/LiliCosic), [Matej Gera](https://twitter.com/gmat90), [Michael Hoffman](https://github.com/MichaHoffmann), [Saswata Mukherjee](https://twitter.com/saswatamcode), [Sonia Singla](https://twitter.com/soniasinglas).

I would also love to thank the CNCF Staff who did a massive amount of work for us: Nicolette Oliaro and Lindsay Gendreau. Thanks also to the AV engineers and the venue staff in our room, ensuring our event runs as smoothly as possible.

Finally, thanks to all the speakers and attendees for your activity and knowledge shared!

### Lessons

To summarize, let's enumerate a few important things I learned during the process.
Maybe more relevant to future myself and those who seek to organize events in the CNCF space in the future:

* Focusing on one subject works well for a half-day. We had mostly the same group of people staying with us for a few hours, leading to amazing connection and activity.
* Embrace last-minute changes. Have backup plans. This means, sometimes having someone fill the 20m talk slot with ad-hoc talk (yes), changing the order of talks if needed and having co-speakers for emergency backup purposes.

![yolo](/images/blog/thanoscon/thanoscon2.jpg)

> Dry-running with [Harshitha Chowdary Thota](https://twitter.com/ThotaHarshitha) 30m before closing talk. Late? Well, last-minute changes forced us to do so and that's fine!

* Always dry-run your talks, even if it's only opening, or closing talk. Ideally weeks before the presentation, but if needed, do it just before the talk. Nothing replaces practice.
* Either organize with care or don't organize. For instance, the event won't moderate itself. While there is a venue staff and speakers mostly know what they are supposed to do, organize [MCs](https://en.wikipedia.org/wiki/Master_of_ceremonies). Prepare and introduce the speakers ahead of time, ideally with personal notes. Don't ignore that part, make speakers and audience feel welcome. Literally all talks I did on KubeCon except for ThanosCon were yolo without introduction or anybody moderating questions afterwards, it's a new pattern I don't like (:
* As a co-located event from the organizing/logistic perspective you have to be strict with the talk timings, so the participants looking for one particular talk can join. This is not ideal, because you can't improvise with the event timing when one talk needs more time and another finishes early. This means either awkward wait times in between the talks or surprise people. Both are frustrating, but the latter is probably more--happened to me at another co-located event where I wanted to attend one particular talk but got into a previous one that somehow was 30m longer than it should have been (moderation issues/last-minute changes?).
* Avoid politics, especially while organizing. Less talking, more doing, and it does not matter who contributed what, focus on the end result, honesty and open heart--don't create environments where members are afraid to surface hard truths.

## Summary

It was supposed to be a quick write-up, but ended quite long. If I plan to write more on this blog (I would love to, it was so refreshing to get back to writing!) I have to condense it a bit (:

As always, feedback is welcome. I only had positive feedback about the event (except the sponsorship part), but I would love to learn what you would change, in retrospect. Let me know!

Stay strong!
