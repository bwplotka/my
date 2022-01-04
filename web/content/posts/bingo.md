---
authors:
- name: "Bartek Płotka"
date: 2020-06-28
linktitle: Need to Version Go Tools for Your Project? That's a Bingo! 
type:
- post 
- posts
title: Need to Version Go Tools for Your Project? That's a Bingo! 
weight: 1
categories:
- go
- infra
images:
- "/og-images/bingo-demo.gif"
featuredImage: "/og-images/bingo-demo.gif"
---

_See bigger version of the above demo as .gif [here](https://raw.githubusercontent.com/bwplotka/bingo/master/examples/bingo-demo.gif)_

In this blog post, I would like to introduce [`bingo`](https://github.com/bwplotka/bingo), a simple and efficient CLI (Command Line Interface) Tool ,
I wrote for managing versions of Go binaries that are required for your project development.

**TL;DR: `bingo` is built on top of the native [Go Modules dependency management](https://github.com/golang/go/wiki/Modules) and in my opinion,
it solves the hard problem of flexible versioning developer tools written in Go. It already improves our integration with tools in the 
production-grade projects like [Thanos](https://thanos.io). Check it out and contribute!🤗**

# Automate all the things!

![This is NOT what you want to do in your project...](/images/blog/bingo/automation.gif)

> Automation is **amazing**. 

Especially nowadays, all projects, whether open or closed source, use at least bunch of tools to automate some tasks. For example in Go community
you can see following popular tools:

* Running tests:  `go test`, `go test -race`
* Benchmarks: `go bench`, [`benchcmp`](https://pkg.go.dev/golang.org/x/tools/cmd/benchcmp?tab=doc), [`benchstat`](https://godoc.org/golang.org/x/perf/cmd/benchstat), [`funcbench`](https://github.com/prometheus/test-infra/tree/master/funcbench)
* Auto formatters: `go fmt`, [`goimports`](https://godoc.org/golang.org/x/tools/cmd/goimports)
* Static analysis: `go vet`, [`lint`](https://github.com/golang/lint), [`golangci-lint`](https://github.com/golangci/golangci-lint), [`faillint`](https://github.com/fatih/faillint)
* Documentation Generators: [`embedmd`](https://github.com/campoy/embedmd), [docs auto generators](https://github.com/thanos-io/thanos/tree/master/scripts/cfggen)
* Build tools: [`goreleaser`](https://github.com/goreleaser/goreleaser), [`promu`](https://github.com/prometheus/promu)
* Other projects (!) you want to run integrations tests against.
* ...and millions of other tools: [website builder](https://gohugo.io/), [link check](https://github.com/raviqqe/liche), [copyright checker](https://github.com/thanos-io/thanos/tree/master/scripts/copyright), protobuf + gRPC generation, jsonnet generators and bundlers, [YAML tools](https://github.com/brancz/gojsontoyaml), etc... 

I could list even more, and to be honest, I am so amazed with the amount of things we have **for free**! They help to maintain a very good quality of the
project, and saves an enormous amount of time. 

# Problem that [`bingo`](https://github.com/bwplotka/bingo) solves

So what projects do? They obviously tend to use gazillion of those tools, reusing amazing ideas and solid code that someone else in open source wrote
and maintains every day with love.

That's great, but how many times you have cloned the project, want to contribute run `make` and see things like:

```shell
$ make 
zsh: command not found: clang
zsh: command not found: goimports
zsh: command not found: goreleaser
zsh: command not found: hugo
```

And that's even a nice error! Usually, you get a confusing error that does not make any sense like: 

```shell 
$ make 
dafg;lkghd;lsfjgpdsjgp 
zsh: exit 1
```

...because you have the required tool installed but **WRONG version** of it!

Now, if you want to be a nice project to work with, you give a hand and either print meaningful errors and tells how
to install a dependant tool and what version of it, in case of users not having a tool or have the wrong version installed. This is 
a step in a good direction, but in my opinion **we can do much better.**

## Installing Tools for User
 
In all projects I maintain, we tried hard to be even more explicit and helpful by ensuring our scripts will install all dependencies
needed manually. We also largely leverage a good, old school [`Makefile`](https://www.gnu.org/software/make/manual/make.html) for tasks like this.
It is as easy as:

```makefile
DEPENDENCY_TOOL = $(GOBIN)/tool 

task: $(DEPENDENCY_TOOL)
	@do task using $(DEPENDENCY_TOOL)

# Will be built only if $(GOBIN)/tool file is missing.
$(DEPENDENCY_TOOL):
	@install tool
```     

## Always Pin the Version

The above example works great, but obviously will not always work if you require a **certain** version of the tool.
If you would remember only one thing from this blog post, remember this:

> You really want to pin version of ALL the tools your project depends on!

Why? Well, the quick answer is that versioning is hard and things are constantly moving. Tools are being improved and changed every day.

Trust me, the last things you want to do is to investigate why CI constantly fails or have the spam of bugs and issues, about someone, somewhere
being unable to build your project because of an obsolete, or a too new tool that was required.

We can easily extend our above `Makefile` example to improve resiliency and development experience by pinning tools' versions
and maintaining immutable binary files.

Immutable binary names safeguard us from accidental usage of the wrong version that might have been installed outside. There is nothing worse than chasing a non-existing issue, only to realize you use the wrong version.

Without immutability, we would have to checksum and verify all build to ensure the correct version which is doable, just a bit more complex to maintain. (BTW, how nice it would
be to have CLI `man` equivalent for printing `version`! (: ). 

We can achieve immutable binary names, as follows:   

```makefile
DEPENDENCY_TOOL_VERSION = v1.124.3
DEPENDENCY_TOOL        = $(GOBIN)/tool-$(DEPENDENCY_TOOL_VERSION)

task: $(DEPENDENCY_TOOL)
   @do task using $(DEPENDENCY_TOOL) 

# Will be built only if $(GOBIN)/tool-v1.124.3 file is missing.
$(DEPENDENCY_TOOL):
   @install tool@$(DEPENDENCY_TOOL_VERSION)
   @cp tool $(DEPENDENCY_TOOL)
```     

## Cross-Platform Installation of the Correct Version of Tools

Version pinning was easy, right? Now, fun stuff, how can we reliably install those tools in the required version? Let's look at possible solutions:

### Commit built, dependant binaries straight to your VCS (e.g git) 😱

This is usually **a bad idea**. While it might work for you, other users would probably want to run your software on different
machines with different architectures and different operating systems, etc. And even if you would host all permutations of
each required binary, each can "weight" from 10-100MB which is most likely too much for common VCSs (e.g `git`). This
will make it extremely slow, if not impossible to clone your project. Plus there is no merge conflict resolution that
works well for binary files.

Hope I made this clear: Please don't do this. (:  

### Use Package Manager

Now, this is what's usually recommended, and it looks innocent.

![Use Package Manager they said...](/images/blog/bingo/pkg.jpg)

The idea would be to use the package manager available on the user's OS e.g. `apt` `yum`, etc.

I will stop here because in practice this is impossible. Let's look at the following reasons:

* While there are standard package managers for major operating systems, some people might not use it (you can disable it).
On top of there are 99% chances that the amazing tool you need is not packaged there or the version available is extremely old.
* There are other custom pkg managers like `snap`, `brew`, `npm`, `pacman` `NuGet` `pip` but not everybody has them 
preinstalled, so it's `chicken & egg` problem.
* Most of the tools work only with tools written in a certain programming language that is NOT Go (:

### Curl Released Binaries

You can probably get quite far with just automatic `curl` of pre-built binary against the certain operating system, released on
GitHub by authors. Unfortunately, again, in practice, not many projects maintain that. Especially, for a small tool, it's an overkill.  

### Pre-Build Container Images

That is quite a fancy solution and has many benefits (portability, isolation, etc). This is great but comes with the tradeoff of
long and non-trivial bake times, overhead, and latency when running a job inside a container.

On top of that, you have to most likely share files between guests and hosts, which is always clunky and problematic (permissions, paths, file ownership, etc).

### Solution: Pin Certain version of Source Code Instead! 

Have you spotted a certain pattern among all the tools I mentioned in [Automate all the things!](#automate-all-the-things) section?

**Yes! They all are written in [Go](https://golang.org/).** The Go community believes in automation, so the amount of tools that was produced is **impressing**. And those are NOT only useful for Go projects but actually any project of it. Tools written in Go tend to be extremely reliable and very easy to maintain and fix. You should try writing your own tooling in Go as well, check [this amazing video](https://www.youtube.com/watch?v=oxc8B2fjDvY) from our friend [Fatih](https://twitter.com/fatih) ❤️ on how to write language tool (e.g linter).

So, if we assume all our tools will be written in Go, does this simplify our life? The answer is: Yes!

#### Rant About Go Modules
 
![Calling Go Modules for help!](/images/blog/bingo/gomod.jpg)

A few years ago Go Team released its sophisticated answer for dependency problem in Go Community: [Go Modules](https://github.com/golang/go/wiki/Modules).
It (usually) works and it's quite amazing for many reasons: 

* It is decentralized. Anyone can publish their code, anywhere.
* Finally, Go projects do not need to be inside `$GOPATH`
* Supports using multiple different (major) versions of the same module in the same build. 
* It is ~secure. HTTPS and SSH are the default and `go.sum` exists to verify checksums.
* Supports caching proxies/mirroring.
* Semantic Import Versioning 
* It is an official tool, which means finally a single standard. They are also built-in other Go tools. 

But let me say this loud and clear: **It's also far from being perfect.** Consider the following reasons:

* It assumes everyone uses **semantic versioning** properly. 

> Halo Go Team, can I have your attention for a second? 🤗 

**99.9% of Go projects do NOT use semantic versioning properly and NEVER will be!** 

It's because maintainers either have no time, don't care or they simply semantically version their APIs or part of packages only. See [detailed 
discussion on this matter in Prometheus (30k stars' project) mailing list.](https://groups.google.com/forum/#!searchin/prometheus-developers/Go$20Modules%7Csort:date/prometheus-developers/F1Vp0rLk3TQ/TyF2WxlkBgAJ)

This leads to most of the problems users experience. You can't escape from a huge amount of `replace` hacks.
Plus, instead of making it easier for such use cases, Go blames others. ):

This is also why `bingo` was needed and why I built it.

* We build and import packages, but version modules. If you add an overhead of maintaining modules and releasing it (see the above issue),
it's clear that maintaining multiple modules is not a good answer. That's why [Duco's](https://github.com/Helcaraxan) amazing [`modularise`](https://github.com/modularise/modularise)
the project was born. It would be better if we have good out of box solution instead.

* Managing Major versions are painful. Rewriting path for everything to include this `v2` is very nasty and tedious, but the only
way of doing a major release and still support multi-version of the same dependency. I hope it will get redesigned someday.

* Vendoring is allowed and sometimes even (😱) recommended. This is opinionated and controversial, but **why would you use `git` if you want
version things in subdirectories, are we in 2005 again?** If for cache purposes, then let's use cache instead. (: Probably a
good topic for the next blog post. I would love to see better and easier ways to use proxies instead. For now, you can read some details [here](https://groups.google.com/d/msg/prometheus-developers/WLQQd_uNRlw/zKyTD9C4BQAJ) 

> I was complaining a bit, but keep in mind that building solution that meets all the requirements
from tiny projects to madly huge mono-repos in both close and open source is extremely challenging.

Overall Go Team is doing an amazing job and Go Modules is the best what you can use now in the Go Community.
It's also improving every day and it's fairly easy to extend as you will read later on. 

### World Without Bingo

Adapting Go Modules to pin buildable dependencies as dev tools for your project is something that
many tried to achieve. One of the major patterns that emerged recently is the [`tools` package with optional separate single Go module.](https://github.com/golang/go/issues/25922#issuecomment-412992431)
This was initially recommended by [Paul](https://twitter.com/_myitcv) who co-organizes popular Go Meetups, here in London, UK. This was also 
mentioned in [`golang/Wiki`](https://github.com/golang/go/wiki/Modules#how-can-i-track-tool-dependencies-for-a-module).

The idea is to simply maintain a separate Go code file that will import all buildable (main) packages
the project depends on:

```go
//+build tools
package tools

import (
   _ "github.com/brancz/gojsontoyaml"
   _ "github.com/campoy/embedmd"
   _ "github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb"
   _ "github.com/google/go-jsonnet/cmd/jsonnet"
   _ "github.com/google/go-jsonnet/cmd/jsonnetfmt"
   _ "k8s.io/code-generator/cmd/client-gen"
   _ "k8s.io/code-generator/cmd/informer-gen"
   _ "k8s.io/code-generator/cmd/lister-gen"
   _ "sigs.k8s.io/controller-tools/cmd/controller-gen"
)
```

Thanks to that, Go Modules will track all those modules that contain these "main" packages (buildable packages) as normal dependencies.
This will be done in the exactly same way as any other library imported in the code and required to build your project, in the main `go.mod` of the project.

Additionally, thanks to `+build` build tag you can make sure this file is not compiled and included in the output build.

The tiny extension of that idea is to have a  small, separate Go Module defined for those tools to make sure those will be not pulled whenever someone imports the main module (especially important for Go libraries). It also reduces the pain of managing cross dependencies.

With this you can do `go install -modfile=tools.mod <package>` which will install the pinned version. You can see an example of such 
use case in [`prometheus-operator`](https://github.com/coreos/prometheus-operator/blob/master/scripts/tools.go) project. 

On top of that, there is [`gobin` tool written by Paul which allows automating this procedure a little bit.](https://blog.myitcv.io/2018/10/24/github.com-myitcv-gobin.html)

Now, while those are actually very nice steps in a good direction, but still there are some major downsides:

* **You still have quite a major burden of fighting with dependency hell. When upgrading single tool you need to fight will all cross dependency
incompatibilities**
* Still, there are some manual steps here. Especially around adding/removing or upgrading tools with `tools.go` pattern.
While `gobin` helps a little, you still need to install `gobin` somehow to use those tools, so there is a chicken & egg problem here.
* You have to "remember" full package installation path whenever you want to use the tool.
* You still do not guarantee that ran binary has a certain version.

#### Multiple Versions of The Packages Inside The Single Module.

On top of that, there is a quite major limitation: One cannot install different versions of the same (or different) package within the same module.
And that's a pretty popular use case, consider following real scenarios:

1. [Prometheus](https://github.com/prometheus/prometheus) has a single module for multiple packages. For example, it has multiple, useful `main` packages:

* `cmd/prometheus`
* `cmd/promtool` 

It's plausible that project may require `prometheus` for end-to-end tests as well as `promtool` for other reasons. The problem is, that with the `tools.go` solution, I can only install those tools from the same commit. This is bad because if for some reason I cannot upgrade `promtool` I am blocked with `prometheus` upgrade as well.
  
2. To extend the above example, inside [Thanos](https://github.com/thanos-io/thanos) we heavily care about quality and tests. Since 
Thanos in some way extends Prometheus, we run integration tests against different versions of Prometheus. Ideally, we would love to install all minor versions:
`prometheus-v2.2.0`,`prometheus-v2.3.1`, ... , up to `prometheus-v2.18.1` to run [each against our tests](https://github.com/thanos-io/thanos/blob/e7d431d3ebf4539d8519196c732a1371481e3d98/pkg/testutil/e2eutil/prometheus.go#L94). Again this is impossible with the mentioned pattern.

To sum, up the existing solutions were not sufficient to solve all the needs a project can have.

## Introducing Bingo

This is where [`bingo`](https://github.com/bwplotka/bingo) comes handy!

While maintaining larger projects like [Thanos](http://thanos.io/), [Prometheus](http://prometheus.io), [grpc middlewares](https://github.com/grpc-ecosystem/go-grpc-middleware), we
found a common set of features that every open-source (especially Go) project would benefit from.

This is why `bingo` has the following features: 

* It allows maintaining separate, hidden, nested Go modules for Go buildable packages you need **without obfuscating your own module or worrying with tool's cross dependencies**!
* Package level versioning, which allows versioning different (or the same!) package multiple times from a single module in different versions.
* Works also for non-Go projects. It only requires the tools to be written in Go.
* No need to install `bingo` in order to **use** pinned tools. This avoids the `chicken & egg` problem. Only `go build` required.
* Easy upgrade, downgrade, addition, or removal of the needed binary's version, with no risk of dependency conflicts.
    * NOTE: Tools are **often** not following semantic versioning, so `bingo` allows to pin by the commit.
* Immutable binary names, which gives a reliable way for users and CIs to use the expected version of the binaries, with reinstall on-demand only if needed.
* Optional, automatic integration with Makefiles.

The key idea is that after installing (`go get github.com/bwplotka/bingo`) you can manage your tools similar to your Go dependencies via `go get`:

```shell
bingo get [<package or binary>[@version1 or none,version2,version3...]]
```

Once pinned, anyone can reliably install correct version of the tool either doing:

```bash
go build -modfile .bingo/<tool>.mod -o=<where you want to build> <tool package>
```

This is quite powerful, as you can use / install those binaries without `bingo`. This makes `bingo` only necessary if
you want to update / downgrade / remove or add the tool.

Alternatively you can use `bingo` itself to install all pinned tools (or one):

```bash
bingo get <tool>
```

Overall, `bingo` allows to easily maintain a separate, nested Go Module for each binary. By default, it will keep it `.bingo/<tool>.mod`
This allows to correctly pin the binary without polluting the main go module or other's tool module.

Also, make sure to check out the generated `.bingo/Variables.mk` if your project uses `Makefile`. It has useful variables 💖to include which makes installing pinned
binaries super easy, without even installing `bingo` (it will use just `go build`!). For `shell` users, you can invoke `source .bingo/variables.env` to source those variables. 

See an extensive and up-to-date description of the `bingo` usage [here](https://github.com/bwplotka/bingo#usage).

### Examples:

Let's show a few examples on popular `goimports` tool (which formats Go code including imports):

1. Pinning latest `goimports`: 

    ```shell
    bingo -u get golang.org/x/tools/cmd/goimports
    ```

    This will install (at the time of writing) binary: `${GOBIN}/goimports-v0.0.0-20200601175630-2caf76543d99`

1. After running above, pinning (or downgrading/upgrading) version: 

    ```shell
    bingo get goimports@e64124511800702a4d8d79e04cf6f1af32e7bef2
    ```

    This will pin to that commit and install `${GOBIN}/goimports-v0.0.0-20200519204825-e64124511800`

1. Installing (and pinning) multiple versions: 

    ```shell
    bingo get goimports@e64124511800702a4d8d79e04cf6f1af32e7bef2,v0.0.0-20200601175630-2caf76543d99,af9456bb636557bdc2b14301a9d48500fdecc053
    ```

    This will pin and install three versions of goimports. Very useful to compatibility testing.

1. Unpinning `goimports` totally from the project: 

    ```shell
    bingo get goimports@none
    ```
    
    _PS: `go get` allows that, did you know? I didn't (:_

1. Editing `.mod` file manually. You can totally go to `.bingo/goimports.mod` and edit the version manually. Just make sure to `bingo get goimports` to install that version!

1. Installing all tools: 
    
    ```shell
    bingo get
    ```

1. Bonus: Makefile mode! If you use `Makefile` , `bingo` generates a very simple helper with nice variables. After running any `bingo get` command,
you will notice`.bingo/Variables.mk` file. Feel free to include this in your Makefile (`include .bingo/Variables.mk` on the top of your Makefile).
    
    From now in your Makefile you can use, e.g. `$(GOIMPORTS)` variable which reliably ensures a correct version is used and installed.
    
1. Bonus number 2! Using immutable names might be hard to maintain for your other scripts so `bingo` also produces environment variables you can source to you shell. It's as easy as:
 
    ```shell
    source .bingo/variables.env
    ```
   
    From now on you can use, e.g. `$(GOIMPORTS)` variable which holds currently pinned binary name of the goimports tool.

## Summary & Future

Thanks for reading this through! I hope you found this insightful. Feel free to try `bingo` out. As always, it's free and
open source. 

This being said, any feedback and contributions are welcome! Just use GitHub Issues and Pull Requests as usual. 🤗
You can already look through [open GitHub Issues](https://github.com/bwplotka/bingo/issues) and check those with `help wanted` label.

Ideally, it would be nice for such tooling to be part of Go. Hopefully projects like `bingo`
and `gobin` will help (a little) to make that happen. In fact, I know Paul from [Go London Meetup he co-organizes](https://www.meetup.com/LondonGophers) and
we already started discussion about [joining forces](https://github.com/myitcv/gobin/issues/96)  so we may have time to try more ideas!🤗 

However, until Go has a full answer to this problem, enjoy `bingo` and feel free to help us maintain this project! (:
