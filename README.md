# my

[![Netlify Status](https://api.netlify.com/api/v1/badges/02f6ed51-669c-4c11-a81e-8c683774cc3b/deploy-status)](https://app.netlify.com/sites/bwplotka/deploys)

Source for [bwplotka.dev](https://bwplotka.dev) personal website including blog posts.

### What it includes?

* Overview
* Blog posts
  * YOLO comments reusing Github Issues (yes ^^)

### What open source tools I used to build this?

* [Hugo](https://gohugo.io/overview/introduction/)
* Theme [KeepIt](https://github.com/Fastbyte01/KeepIt))
* Improve favs & facebook linking: https://realfavicongenerator.net
* Netlify :heart: and it's free tier for open source projects!
* Tiny amount of jquery
* Awesome Github client for JS: https://octokit.github.io/rest.js/

### What YOLO comments means?

Features:

* Using github issues as comments. For full discussions as well.
* On website in comment sections it gives you index overview of comments, nothing more.
* Prints all issues related to issue. Based on labels. For each new blog post new gh label has to be created (: (is there a label num limit?)
* It does not care about issue status, can be even closed.

Limitations:

* No dynamic reload
* Nested responses not rendered - only as numbers
* No markdown support
* It points to issue filtered list so not really user friendly for new comments I guess
* Trimming all above 200 chars

### Can I copy the code for my own website?

Of course, all except (blog content) is licensed with Apache 2 license.
