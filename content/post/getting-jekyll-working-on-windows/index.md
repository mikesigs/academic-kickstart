+++
title = "Getting Jekyll Working on Windows"
date = 2016-03-03
draft = false

# Tags and categories
# For example, use `tags = []` for no tags, or the form `tags = ["A Tag", "Another Tag"]` for one or more tags.
tags = []
categories = []

# Featured image
# Place your image in the `static/img/` folder and reference its filename below, e.g. `image = "example.jpg"`.
# Use `caption` to display an image caption.
#   Markdown linking is allowed, e.g. `caption = "[Image credit](http://example.org)"`.
# Set `preview` to `false` to disable the thumbnail in listings.
[header]
image = ""
caption = ""
preview = true

+++
It's been almost a year since I started this blog. Sad to say, this is only post #2. Right after I got everything set up and published my first post, wouldn't ya know it... my machine died on me. ~~I recall it being kind of a pain getting Jekyll working on Windows and I just couldn't bring myself to start all over again. Fortunately, a lot has changed in the last 10 months and it is now a cinch to install Jekyll on Windows. Let's get started!~~
**Update:** I am now using [Hugo](https://gohugo.io). Getting started is waaaaaay easier than with Jekyll. Mostly because you don't have to setup and maintain a ruby environment. Definitely check it out!

## Install Chocolatey

First of all, if you don't [Chocolatey](https://chocolatey.org/) installed, now's the time. No, really. Now _is_ the time because you're going to need it to follow the rest of these instructions.

Open **cmd** as Admin and run the following command:

```PowerShell
C:\> @PowerShell -NoProfile -ExecutionPolicy Bypass -Command "iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))" && SET PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin
```

Now, close and reopen **cmd** as Admin.

## Cmd... Really?

Truth be told, **cmd** is ugly and a pain to work with. Let's install something better.

Personally, I like [cmder](http://cmder.net/). It uses [Conemu](https://conemu.github.io/), [Clink](https://mridgers.github.io/clink/), and [msysgit](https://msysgit.github.io/) to provide a superior console on Windows. It looks great out of the box too, using the Monokai color scheme. It's also extensible via Lua scripts. Leave a comment below if you'd like to hear more about some of the Lua customizations I use in my own setup.

You can install cmder using Chocolatey by running this command:

```PowerShell
C:\> cinst cmder -y
```

Another alternative is to use [posh-git](https://dahlbyk.github.io/posh-git/), a PowerShell environment for Git, which gets installed with [GitHub for Windows](https://desktop.github.com/). I've heard good things, but don't use it myself. You can install it using Chocolatey too by running this command:

```PowerShell
C:\> cinst github -y
```

Neither of those fancy-shmancy shells are really necessary to get Jekyll running on Windows. But trust me, between Jekyll and Git, you'll be spending a lot more time in the console and it will only make your life better by having one installed. Perhaps the biggest gift provided by each is the msysgit tools, which I do actually use later in these instructions. So yeah, it's "*optional*", but only if you hate yourself.

## Install Ruby

Now that we have Chocolatey installed we can very easily install Ruby like so:

```PowerShell
C:\> cinst ruby -y
```

This installs Ruby (version 2.2.4 at the time of writing) to `C:\Tools\ruby22\`. If for some reason you don't find it there, check the value of the `%ChocolateyBinRoot%` environment variable to see where Chocolatey installs portable/stand-alone apps by default.

## Ruby DevKit

There are a number of Gems that require the Ruby DevKit to be installed. Let's install that too:

```PowerShell
C:\> cinst ruby2.devkit
```

To finish setting up the Ruby DevKit we need to tell it where our "Rubies" are. Open the file `C:\Tools\DevKit2\config.yml` in your favorite editor and add " - C:\\Tools\\ruby22\\" to the end of the file (including the leading space, but not the quotes).

Save and close the file and run the next command to complete the DevKit installation.

```PowerShell
C:\Tools\DevKit2\> ruby dk.rb install
```

## Update RubyGems SSL Certs

This is the part that frustrated me the most, and was the real motivation for writing this post in the first place.

A year ago when I first setup all this stuff the SSL certs in RubyGems on Windows were all old and broken and you couldn't even install gems without first changing the source to a non-https source. Fortunately, recent versions seem to have fixed this... kind of. I still ran into SSL errors when trying to follow the instructions for [configuring the github-pages gem](https://jekyllrb.com/docs/github-pages/). Which, if you're using Jekyll and plan to deploy to GitHub Pages, you're going to want to use that gem too.

The solution is to download the latest and greatest bundle of CA Root Certificates and tell RubyGems where to find it by setting an environment variable. You can download the file manually from <https://curl.haxx.se/ca/cacert.pem> and save it in `C:\Tools\ruby22\lib\ruby\2.2.0\rubygems\sslcerts\`. 

Or if you have msysgit installed you can download it using `curl` by running the following command:

```PowerShell
C:\> curl -Lk https://curl.haxx.se/ca/cacert.pem -o "C:\Tools\ruby22\lib\ruby\2.2.0\rubygems\ssl_certs\cacert.pem"
```

However you did it, you're gonna need to create a system environment variable `SSL_CERT_FILE` and set it to `c:\bin\ruby22\lib\ruby\2.2.0\rubygems\ssl_certs\cacert.pem` so RubyGems knows where to find the updated cert file.

## Off To The Races

That's it. You're now ready to create your site using Jekyll. You can start from scratch using `jekyll new mySite`, or you can clone an existing theme (what I did). There's a great list [here](https://github.com/jekyll/jekyll/wiki/Themes).

Happy blogging!
