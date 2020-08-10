---
authors:
- name: "Bartek Płotka"
date: 2020-10-03
linktitle: The Definitive Guide for Mentoring Devs in Open Source ...and Beyond
type:
- post 
- posts
title: The Definitive Guide for Mentoring Devs in Open Source ...and Beyond
weight: 1
categories:
- open-source
featuredImage: "/images/blog/mentoring-guide-2020/sonia-fun2.png"
---

## Mentoring: The Hard Truth

Nowadays, mentoring might be one of the most `undervalued` activity you can bring to your company, organization or project.

> Let's be honest. What is the first thing you feel when thinking about *mentorship*? 

From the perspective of `the mentor` mentoring is usually considered with feeling of wasted time, distractions,
repetitive questions and necessity to fix the broken stuff after the student finishes. On the other hand, `potential mentee`,
usually feels confusion with the mentorship purpose, embarrassment to admit their lack of knowledge or misunderstanding of task
and overall fear of failing or taking too much time of busy mentor. Lastly, `the organization or company leadership`'s first
impression is the amount of spent $$$ on employee time used for mentoring instead of company goals.

Now, all of this are fair feelings based on the usual experience. I experienced exactly those unhealthy feelings from all
three perspective during my career. It was hard to motivate myself mentally to start mentoring again. 

However, with the start of the 2020, we did. 🎉 We redesigned mentorship from scratch, experimented with new ideas and... it boomed! 🤩 
**Together with [the CNCF's](https://www.cncf.io/) open source projects [Thanos](https://thanos.io), 
[Prometheus](https://prometheus.io) and during my employment at Red Hat I have been personally mentoring / co-mentoring 11 amazing engineers
this year with great fun and success!** (not mentioning 4 more being selected for 2020 Q3 round of open source mentorship).

All of this ☝ without major distractions. I was still maintaining open source projects, performing on-call duties, working as team lead on OpenShift Observability and [CNCF SIG tech lead](https://www.bwplotka.dev/2020/sig-obs-tl/).

In this, rather lengthy blog post, I would love to share some **actionable, organizational, technical and behavioral tips and recommendations
for successful, healthy, non-distracting mentorship.** Suggested for all mentors who are looking to boost their mentoring skills. I wished I
had so much insight to other's mentorship process in the first place.

### Open Source Scholarship Programs vs Private Company Internship?

Ultimately, both activities share the same similar goals for both students and organizers. It allows a student to be introduced to the 
open source world or company and have meaningful experience and record in the CV, for the company / project you teach and motivate potential
full time maintainer or employee.

At the end for both you really need [effecting mentoring to make it productive](https://www.linkedin.com/pulse/mentoring-difference-between-internship-summer-job-shindell-ph-d-/), so
while both have different problems (which will be mentioned later), overall this guide should be applicable for both, equally. 

# The Guide

Aka: How to avoid exhaustion, stress and mentoring burnout. (: 

  * [Organizing Mentorship](#organizing-for-mentorship)
  * [Mentee Selection](#mentee-selection)
    + [Step 1: Initial Process](#step-1--initial-process)
    + [Step 2: Questionare](#step-2--questionare)
    + [Step 3: The 30m Call](#step-3--the-30m-call)
    + [Final step: Decision!](#final-step--decision-)
  * [Mentoring Structure](#mentoring-structure)
    + [Meetings](#meetings)
    + [Async channels](#async-channels)
    + [Introduction to the Community / Company / Team](#introduction-to-the-community---company---team)
  * [During Mentorship](#during-mentorship)
    + [Clear expectations](#clear-expectations)
    + [Start small](#start-small)
    + [Allow independence.](#allow-independence)
    + [Don't be a blocker, teach pragmatism](#don-t-be-a-blocker--teach-pragmatism)
    + [Never sacrifice best practices](#never-sacrifice-best-practices)
    + [Details might matter](#details-might-matter)
    + [Everyone wants Team Players](#everyone-wants-team-players)
    + [Pair-do things. It's nothing better than seeing how you do things.](#pair-do-things-it-s-nothing-better-than-seeing-how-you-do-things)
    + [Expand their horizons](#expand-their-horizons)
  * [Wrapping up Mentorship](#wrapping-up-mentorship)
    + [Retrospective](#retrospective)
    + [What's Next?](#what-s-next-)

<small><i><a href='http://ecotrust-canada.github.io/markdown-toc/'>Table of contents generated with markdown-toc</a></i></small>


## Organizing Mentorship

2 ppl, CS, GSoC

Announcing, prepare projects.

Marketing key - more diversity! Mention what they can learn.

## Mentees Selection

This is maybe trivial, but it's very often **skipped** step by mentors. Usually people are busy, they don't take part in interviewing
and someone else assigns them a mentee, or there is a separate HR team, who found some student that is good from their perspective for internship with the team.

> Sorry to be blunt, but if you are not part of the selection process, you most likely already lost and increased chances for an unsuccessful mentorship.

Why you should be part of interviewing and decision making? 

Mainly, because everyone is different. If you are passionated person, who loves to teach others (and learn on the way as well!) you most likely care what kind of person
you will be working with for longer time and helping. 

* Maybe project you want student to work on is tricky and you want to focus on mentoring, not teaching basic git commands or language primitives?
* Maybe you look for someone particularly interested in open source and long term association with communities. 
* Maybe you value the most positivity and passion.
* Maybe some person has unique perk that only you see, and you see huge potential to grow based on your experience. 

Everyone is different. You like different kind of people and characters then e.g. you colleague, so you **have to be part of selection process**.
Ideally you want to direct interviews and communication as well. You want to avoid cases when someone chooses you a mentee that won 10
international hackathons but can't speak English or communicate clearly.
 
There is also another important, psychological reason. If you decided to help mentor someone, you agree with all imperfection that person might have. 
In the moment of weakness you can't blame anyone else just you, so you are less likely to give up or completely demotivate. 
Kind of the same is with marriages. (: 

### Step 1: Initial Process 

Ideally as mentioned in the first step you announced and advertised well the mentorship with outlined clear goals, topics and
technologies involved. 
 
Deadline for applications passed and hopefully you see dozens of applications. What's next?

> First rule: Don't rush. No candidate is better than non suitable one.

Based ony your goals, try to get through all of them, fit with your expectations and prioritize a few (e. 10) based on key
elements you are looking for. It can differ, but for case of Prometheus/Thanos mentorship in open source we prioritized:

* Diversity
* Friendly, honest and clear communication. Pro tip: Young person with reasonable number of Twitter followers, or You Tube subscribers
most likely have good communication and friendliness skills.
* Those new to open source, with desire for long term involvement with the community. 
* Prior knowledge of what we do & why. This shows passion and not random application.
* Time availability & work time zone.

### Step 2: Questionare

Of course it's hard to get those information from CV and cover letter. That's with initially selected people we send out further email
questionaire to fill. For example this month we sent email like this:

> Hi!
>
>We have received many applications for Community Bridge under Thanos and Prometheus and are now evaluating applications. Unfortunately, the Community Bridge application form only asks for limited information, and we are reaching out to you for more info to help us make our decision. It would be useful if you could reply with the answers to the following questions:
>
>1. What project you would like to work on (please prioritize from 1 to 3, when bigger means you are more interested):
>  * Prometheus: Query Post-Processing (Go, Backend, PromQL)
>  * Thanos: Receive Hashring Update (Go, Distributed Systems)
>  * Thanos: UI Improvements (React, Go)
>
>2. How long do you think it would take for you to finish the project(s)? A rough estimation is fine; no need to be accurate. If unsure, just skip this.
>The time estimate is more relevant for any of you who have made some contributions to Thanos (or related projects) already. The official program timeline may be helpful as the CNCF community bridge timeline is roughly 2 months long.
>
>3. If you finish the listed project(s) within time, would you be willing to pick up more projects to work on? These will be projects of interest to you (we will not force any particular project/issue) and they can be anywhere in the Prometheus ecosystem
>
>4. Have you ever considered maintaining an open-source project? 
>
>5. How many hours per week and per month do you plan to commit to community bridge? We realize many of you have full-time jobs, summer classes, or other responsibilities, and a lower number is absolutely fine. This is mainly for us to be able to help scope the work you commit to and to adjust our expectations when evaluating your progress.
>
>6. If you have been mentored before (e.g as part of GSoC), what are the reasons for applying for another mentorship program? In the same way, if you have a full-time job with potential learning opportunities there, what are your reasons to apply for this program? This helps us understand your motivations! (:
>
>7. What timezone are you in?
>
>Kind Regards,
>
>Thanos & Prometheus mentors

Feel free to copy and use this for your needs! 🤗 With responses to this you have much more information. It should be easier to prioritize a fewer amount of people for some short 30m call with few mentors.

### Step 3: The 30m Call

Virtual face time! This is where you can learn the most. Most likely, especially these days, the most often type of contact will be through virtual meetings, so 
checking if you can have efficient communication through this kind of mean is the key. How this calls can look like?
 
* Try to be on time.
* Start from casual greetings and checking how they are / how their day looks like. Don't hesitate to mention something personal from your day (e.g Oh, feel good just rolled production second ago!).
This helps potentially younger person to feel ok to be more honest and less tense as well.
* Do quick round of introduction. Start with yourself and tell who you are very quickly. Ask others mentors, then ask politely if the candidate want to share few sentences about themselves as well.
* Explain the purpose of this meeting. To me the goal is to meet and learn more about the candidate, but also to allow a candidate to meet us as well. Remind that at the end (last 10-5min), the candidate 
will have time to ask questions mentors.


Kudos to my previous employer, [Improbable](https://improbable.io) who thought me all those amazing practices for maintaining friendly atmosphere during potentially
stressful technical interviews we were performing when I was there. 

### Final step: Decision!

![tweet](/images/blog/mentoring-guide-2020/sonia-tweet.png)

## Mentoring Structure

### Meetings

* Setup 2:1 meetings. Avoid skipping Those (procrastination)
* Setup working doc; Clear Agenda and action items.

### Async channels

* Setup internal chatting channel but by default direct mentees to speak on public channels

### Introduction to the Community / Company / Team

* Introduce students on the Community Meetings; Make them an important part of the community, make it official.

## During Mentorship

### Clear expectations

* Be clear about expectations and communication style in the project.

### Start small

* Start with small, intro tasks.

### Allow independence.

* Give mentees a fishing rod not a fish. Tell them how would you start solving this, not the solution!  Debugging Sonia.

### Don't be a blocker, teach pragmatism

You don't have time to review immdiately their work.

* Learn the real development: It's fine to have them working on two tasks in the same time (but not more!)

* Make sure mentees are not blocked; give them hand ask them "What have you learned in the last couple of days"; sometimes it's not obvious they can ask for help 

### Never sacrifice best practices 

* Always focus on tiny iterations but without compromising quality. It's fine to have the simplistic feature first with lots of todos, it's not
fine to have ugly code with refactor as todo.

* Proposal process? Don't jump to code too quickly!

### Details might matter

* Be honest even about slight detail that might make their life harder at some career point - you want to help them after all! E.g nodding and "doubt"

### Everyone wants Team Players

* Encourage mentees to review yours and each other PRs!

### Pair-do things. It's nothing better than seeing how you do things.

* There is nothing better than pair programming or pair review!

### Expand their horizons 

* Give them ideas to do more: blog posts; Epic mentees meeting, demos on community meetings.

## Wrapping up Mentorship

### Retrospective

* Wrapping up: Retrospective process.

### What's Next?

Student office hours.

# Summary 
 
Thanks

Huge work to CNCF, mentors, community!


During Summer of 2020, on top of our full-time work, on-call rotations, open source project's work, preparing conference talks and ☕ we had extra
duties: `75%` the [Thanos](https://thanos.io) Team ([Giedrius](https://giedrius.blog/), [Lucas](https://github.com/squat), [Kemal](https://kakkoyun.me/), 
[Matthias](https://matthiasloibl.com/), [Povilas](https://povilasv.me/) and me) and a few members of [Prometheus](https://prometheus.io) Team ([Callum](https://github.com/cstyan),
[Chris](https://github.com/csmarchbanks) and me) were mentoring amazing people in their first steps in the Open Source! 
We taught mostly students but also already experienced developers, all totally new to the [CNCF](https://www.cncf.io/) space and projects. 

We very are grateful that this year's edition were full of smart, diverse and incredibly curious candidates that applied for Thanos and Prometheus
mentoring through [Google Summer of Code (GSoC)](https://developers.google.com/open-source/gsoc) and [Community Bridge](https://communitybridge.org/) programs.
 
The choice was tough, but in the end we decided on four women and three men from a variety of countries: Canada, India, Nigeria, and the USA. Two for Prometheus, 
five for Thanos project.

Hope this helps others


 