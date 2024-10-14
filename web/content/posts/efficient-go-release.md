---
weight: 100
title: "My 'Efficient Go' Book with O'Reilly is Released 🎉"
date: "2022-11-18"
aliases: ["/efficient-go","/book"]
categories:
- go
- books
- efficient-go
- efficiency
featuredImage: "/og-images/efficient-go.png"
---

I would never have believed anyone telling me that such a moment would happen in my life.

Yet it happened--my book was released this week! 🎉

It is one of the things that looked impossible upfront. Not only for me--my family was also shocked when I told them that I was writing this book. I was not very passionate about writing in the past. In high school, I barely passed the final exam for the "Polish language" subject--you know, the one you have to write boring essays about some poems. My interpretation was always wrong, even though they asked for "my" interpretation. (There is an old joke in Poland that claimed [Wisława Szymborska](https://en.wikipedia.org/wiki/Wis%C5%82awa_Szymborska), a famous Polish poet, did a similar exam undercover for fun--and she was meant to interpret her own poem. Apparently, she failed that exam). Similarly, my bachelor thesis at my University (Computer Science course) was a 4-people project. Obviously, I took the coding part with one colleague and I don't remember touching (or reading) the writing part (don't tell anyone!). Hopefully, this tells you how I could be seen as the last person who would write a book...

After ~1300 hours (within ~20 months), I finished the book and learned so much from this journey! In this post, I would like to give basic information about the book, give some sneak peeks and share some thoughts about my writing process (with [some photos](#work-book-writing-travels) near the end!).

## Book

The topic and reasons for the book were mentioned in my previous announcements ([1](/2021/efficient-go), [2](../efficient-go2)). The TL;DR is that the "Efficient Go" book is a complete, pragmatic guide about everyday software efficiency--so how to reduce latency and consumption of computing resources (e.g. CPU and memory). Why do we have to care, why it's not only needed in "high" performance / low latency systems, what are the risks when we care too much about it, how to prioritize, measure and apply efficiency. The cost of our systems matters, so knowing how to reduce it is an important skill, especially in recession times 🙃.

I use Go programming language as an example code you might need to optimize. Still, most chapters are language agnostic--the same will apply to Python, Java, C#, JavaScript etc. I found Go to be perfect for this kind of content. It's not too high level and does not have too complex runtime compared to, e.g. JVM, so introducing this "mechanical sympathy" towards efficient execution is simpler. It's also not too low level, which makes it very practical and easy to use and read, which ideally is not sacrificed when you make your code faster or leaner. Overall, while Go is sometimes chosen for "better" performance over other languages, generally, the industry came up with dedicated languages for speed and efficiency--languages like Rust, C/C++ or Carbon. The choice of Go is perfect, in my opinion, because I want to teach you how to make your "everyday" code more efficient when you need to. In most cases, there is no need to rewrite things in Assembly or Rust!

There are eleven chapters:

![](/images/blog/efficient-go/toc-1.png)
![](/images/blog/efficient-go/toc-2.png)
![](/images/blog/efficient-go/toc-3.png)

The book contains many code examples. I prepared also an open-source repository (link in the book) where you can play with them in your favorite IDE.

Many examples and practices came from years of experience with Go and resulted in some heavy-duty open-source libraries like [`efficientgo/core`](https://github.com/efficientgo/core) and [`efficientgo/e2e`](https://github.com/efficientgo/e2e). If you want to help maintain those, let me know too!

### "Share some book snippets"

> [Ivan on LinkedIn](https://www.linkedin.com/feed/update/urn:li:activity:6997949174461652992?commentUrn=urn%3Ali%3Acomment%3A%28activity%3A6997949174461652992%2C6997996313740984321%29
): It will be awesome to get some snippets from your book here. I’m sure this way more people will get to know about it as well 😛

Why not! It's hard to tell which chapter is my favourite, but I am especially proud of Chapter 9, "Bottleneck Analysis, " which covers Profiling in detail. Those techniques allow us to tell exactly the **main** reason for slowdowns or high consumption usage, e.g. memory in your application. Most likely, that part is the most impactful thing you can change to improve efficiency! Here are two pages (out of 50 in this chapter) discussing heap profiles easily gatherable in Go. There are many less-known details about them--knowing them makes you so much more effective.

![](/images/blog/efficient-go/heap.png)

At the end of this chapter you will learn how to setup continous profiling setup for **free** in minutes, using amazing open source software like [Parca](https://github.com/parca-dev/parca). And it's not just a "toy"--we have been using it in production for ~2 years. 😉 

### How to Get "Efficient Go"?

You can buy my book in many places. Choose whatever makes sense for you, for example:

* [O'Reilly entry point](https://www.oreilly.com/library/view/efficient-go/9781098105709/)
* Amazon ([US](https://www.amazon.com/Efficient-Go-Data-Driven-Performance-Optimization/dp/1098105710), [UK](https://www.amazon.co.uk/Efficient-Go-Data-Driven-Performance-Optimization/dp/1098105710?crid=XH6ZOQIV3IYH&keywords=Efficient+Go&qid=1662479068&s=books&sprefix=efficient+go%2Cstripbooks%2C152&sr=1-2&linkCode=ll1&tag=bwplotka-21&linkId=3c2d7389f9790829cf6bc46d6165f9b3&ref_=as_li_ss_tl), [DE](https://www.amazon.de/Efficient-Go-Data-Driven-Performance-Optimization/dp/1098105710/))
* [Barnes & Noble](https://www.barnesandnoble.com/w/efficient-go-bartlomiej-plotka/1141565108?ean=9781098105716)

E-books are available. If you order a printed copy, be mindful that Amazon is scaring customers with quite a long print & delivery time (~one month during Christmas). Those things are outside of my control, but I heard they tend to overestimate the timing for books, so let's be hopeful! 🤞

### Feedback

I am already getting good feedback from people who managed to read some of the book (and it was about the 9th chapter, so either they skipped a lot or read very fast! 🙈). There is nothing better than good feedback--it's essentially one reason why I create this book. (:

Have you read the book and have questions? Or you found a typo? Or you just wanted to share your opinion about the content?

Please do! For typos, bugs or issues, feel free to use [O'Reilly' Errata` system](https://www.oreilly.com/catalog/errata.csp?isbn=0636920533887). Otherwise, please join our [Discord Community](https://discord.com/invite/7g5MJqFcQG) and ask a question there OR hit me on any channels: [Slack, Twitter, Linkedin or email](/).

### Acknowledgements

As they say, [the greatness is in the agency of others](https://www.profgalloway.com/power/). This book is no different. Numerous people helped me directly or indirectly in my Efficient Go book-writing journey and my career.

First of all, I would love to thank my wife, Kasia—without her support, this wouldn't be possible.

Thanks to my main tech reviewers, Michael Bang and Saswata Mukherjee, for relentlessly checking all the content in detail. Thanks to others who looked at some parts of the early content and gave amazing feedback: Matej Gera, Felix Geisendörfer, Giedrius Statkevičius, Björn Rabenstein, Lili Cosic, Johan Brandhorst-Satzkorn, Michael Hausenblas, Juraj Michalak, Kemal Akkoyun, Rick Rackow, Goutham Veeramachaneni, and more!

Furthermore, thanks to the many talented people from the open-source community who share enormous knowledge in their public content! They might not realize it, but they help with such work, including my writing of this book. You will see quotes from some of them in this book: Chandler Carruth, Brendan Gregg, Damian Gryski, Frederic Branczyk, Felix Geisendörfer, Dave Cheney, Bartosz Adamczewski, Dominik Honnef, William (Bill) Kennedy, Bryan Boreham, Halvar Flake, Cindy Sridharan, Tom Wilkie, Martin Kleppmann, Rob Pike, Russ Cox, Scott Mayers, and more.

Finally, thanks to the O'Reilly team, especially Melissa Potter, Zan McQuade, and Clare Jensen, for amazing help and understanding of delays, moving deadlines, and
sneaking more content into this book than planned! :)

## Writing Process

As I mentioned, writing "Efficient Go" was very insightful. Of course, everybody experiences writing differently, but there was something in it I loved. Something addictive around finding the best way to explain things, finding new patterns that would help clear the information out or (especially) breaking conventional ways of explaining something with unique techniques or analogies.

On top of tht, I think it was quite exciting that you can't write about something you are "not sure". There was extra motivation to understand things very deeply, cross-fact, and research every detail. There is so much information in the software development industry that I learned to ignore some details. For example, before writing a book, I thought I understood `pprof` profiles. I never even noticed advanced topics like refining the profile view in the pprof UI. I tried to use it, found it funky and assumed it was broken or unuseful. Oh boy, I was so wrong, and you will learn in my book why. So many things are well thought through there!

What else I learned:

* Long deadlines are the worst. I started this book around February 2021, and I initially had only a big deadline of "all content" written in December 2021. Guess what, [the Parkinson's Law](https://en.wikipedia.org/wiki/Parkinson%27s_law) applies. In December, I had maybe 2 out of 11 chapters. Then we switched to more strict deadlines for every chapter. I slipped almost EVERY chapter deadline of ~1-2 weeks, but it was done. (:
* Having good publisher like [O'Reilly](https://www.oreilly.com/library/view/efficient-go/9781098105709/) was amazing. You could potentially earn more publishing yourself, but it would either take 5-6 years for me or I would need to leave my full-time job. For a "side" hobby like this, it was perfect. They are professional, respectful, and helpful. They also add some so much-needed discipline to deliver the book at some point. I could focus on content and marketing without stressing about production, print, selling frameworks, issues, building e-books, proof-reading and a million other things.
* The most tricky is to create the initial table of contents. If you do it right it's great. But it is impossible to do it right on your first attempt--you simply have too little information on what you want to focus on. Time window this effort and move on. As long as you maintain roughly the number of pages/chapters, it's totally ok to redesign chapters a lot during the process.
* I was writing from chapter 1 to the last in the order. It was beneficial as I could assume what was explained before when starting a new chapter about more advanced stuff. But there was a downside too--I had less time (and room in terms of pages) for actual advanced stuff. Fortunately, I found room and time for everything I wanted to mention, but it was stressful. I am not sure if I would start from advanced stuff I had to repeat things... sounds like there is no perfect solution here (:
* Writing with a full time job (software engineering) is possible, but it's a stretch. Generally, I could not write book content after (or before) 8-9h of work. What worked for me is to take PTOs, weekends and holidays for book writing. My employer (Red Hat) also had extra recharge days and hack & hustle days, which I (while explicitly mentioning this to my employer) used for book writing.
* Holidays and weekends without a laptop are very important. After ~1y of every possible free time after working on a book, I was a walking zombie. Unfortunately, just time "off writing" was not an option--I was then thinking *I should write now* because of deadlines.
* Notes are game-changing. Note every idea as soon as possible into some quick medium. The best ideas are always happening in the weirdest possible moments--before you sleep, in the toilet, when you read the irrelevant thing. So catch all quickly, then revisit; otherwise, you will forget and only remember that you *had some* good ideas, but you don't know what.
* Using [Goland](https://www.jetbrains.com/go/) to write my book in [AsciiDoc](https://asciidoc.org/) was great, can recommend that. Good to have the same shortcuts, navigational aspects and AsciDocs formatting thx to plugins.
* [Grammarly](https://app.grammarly.com/) Pro was super helpful. Just don't try to use it with more than 5k words. It's too slow. I ended up copying parts of things between the Grammarly editor and Goland. It was quite painful but better than trying to copy whole chapters.
* Splitting writing into different modes was very helpful. I had three "modes":
  * Making notes or organizing them.
  * Writing content without too much scepticism, innovating and researching.
  * Criticism mode, where I was checking and rejecting parts, running through Grammarly, proofreading, etc.
* Use `git` for book content--saved my life.
* Writing takes **a lot** of mental energy--especially if you are an introvert like me. It's silly, but with every word I put, my mind is judging myself on how somebody will take it and how they will think about me after reading. It takes a lot of confidence and hard work to deal with those fears. I actually started a lot of meditation and Yoga skills during the writing period because of that!
* Getting content through technical reviewers as soon as possible was essential. I had so much cringe stuff 🙈. At some point, I started to compare software memory efficiency to car-makers fuel economy efficiency and how we have the same techniques. The chapter was more about cars than software. I removed most of it (for a good reason).

### Work & Book Writing & Travels = ❤️

Finally, travelling helps! A laptop with a better battery would be so helpful--it's much nicer to write in different places. During my writing effort, I did a work & travel trip around Europe with my wife for 2.5 months, and I was quite productive there, despite the distractions:

![Change places often, it actually brings fresh air to your mind! UK, Ashford](/images/blog/efficient-go/ashford.png)

![Small UK villages are the best, seriously! UK, Alsager](/images/blog/efficient-go/alsager.png)

![France, Nancy](/images/blog/efficient-go/nancy.png)

![Switzerland, Weggis](/images/blog/efficient-go/swiss.png)

![To be fair, on this photo I was working, not writing the book, but still a nice photo (: Italy, Lago di Como](/images/blog/efficient-go/ita-lago.png)

![I couldn't do skiing, because of my ACL knee injury. Maybe for the better--I could focus more on my book! Italy, Sella Ronda](/images/blog/efficient-go/ita.png)

![Overheating laptop to the point I could not touch the keyboard was fun. Spain, La Pineda](/images/blog/efficient-go/pineda.png)

![France, Cannes](/images/blog/efficient-go/cannes.png)

## Summary

It's honestly refreshing to get back to some blog posting after book writing. Book definitely consumed my writing energy, but I missed something yolo in blogging. I might visit this space more often--let me know if you would like it!

That's it for today. See you in open-source! ❤️
