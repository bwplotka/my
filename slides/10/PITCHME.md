[drag=100 100, rotate=-3, drop=-38 -28]
# 7 

[drag=100 100, rotate=3, drop=10 -25, set=h1-yellow]
# Life Saving Tips 

[drag=100 100, drop=0 5, fit=0.65]
# for Maintaining Go Projects in Open Source

[drop=0 60]
![width=480](assets/images/slides/GopherSpaceMentor.png)

[drop=32 90, pad=20px]
20.11.2020 | [Bartek Płotka](https://bwplotka.dev) 

Note:

* Things that might be quite innovative or never seen before
but proven to be extremely useful long term when building Thanos project

---

[drag=100 100, fit=0.9]
## 1: Be Transparent in Everything Maintainers Team Does 

Note:

---

[drop=0, fit=0.9]
## 1: Be Transparent in Everything Maintainers Team Does 

[drag=100 100, drop=0 10]
@ol[](true)
* Maintainers Technical Discussions
* Answering Community Questions
* Project Roadmap
* Known Issues and Limitations (even if embarrassing @emoji[smile])
* Mentoring Mentees in terms of Technical knowledge
* Maintainers Meetings
* WIP work
@olend

Note:

Saves time.
Awareness
Build trust,
Separete low level disscussions with end user expierience (e.g thanos-dev normal channels)

---

[drag=100 100, fit=0.9]
## 2: Keep Documentation in the Same Repo (ideally in markdown)

Note:
It's tempting to put docs to separate docs repo like Promethues/docs but it's wrong, why?

---

[drop=10 0, fit=0.8]
## 2: Keep Documentation in the Same Repo

[drag=100 100, drop=0 -30]
Why?

[drag=100 100, drop=0 0]
@ol[](true)
* Updating Documentation in the same PR as change
* Automating deployment of docs for each change & release is much easier
* It's much easier for user to find them and contribute! (`/docs`)
* Auto-generating docs from flags/configs is much easier (and enforcing this!)
@olend

---

[drop=10 0, fit=0.8]
## 3: Deploying Static Website from Markdown on Every PR

[drag=100 100, fit=0.8]
![](assets/images/slides/10/1.png)

Note:

---

[drop=10 0, fit=0.8]
## 4: Auto-generating docs from flags

[drag=70 70, fit=1]
![](assets/images/slides/10/2.png)

Note:

---

[drop=10 0, fit=0.8]
## 5: Auto-generating docs from Go structs!

[drag=70 70, fit=1]
![](assets/images/slides/10/3.png)

Note:

---

[drop=10 0, fit=0.8]
## 5: Auto-generating docs from Go structs!

[drag=70 70, fit=1]
![](assets/images/slides/10/3b.png)

Note:

---

[drop=10 0, fit=0.8]
## 6: Closing & Exhausting io.Readers!

[drag=70 70, fit=1]
![](assets/images/slides/10/4.png)



Note:

pkg/runutil/runutil.go#L149

---
[drop=10 0, fit=0.8]
## 7: Content or File flags

[drag=70 70, fit=1]
![](assets/images/slides/10/5a.png)

---

[drop=10 0, fit=0.8]
## 7: Content or File flags

[drag=70 70, fit=1]
![](assets/images/slides/10/5.png)

Note:
pkg/extflag/pathorcontent.go

---

Note:
---?include=slides/common/thank-you/PITCHME.md
