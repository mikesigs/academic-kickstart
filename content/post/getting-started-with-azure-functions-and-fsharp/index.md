---
title: "Getting Started with Azure Functions and F#"
date: 2018-03-08T22:32:30-07:00
tags: ['Azure', 'F#', 'Azure Functions']
draft: true
---
## Setup your environment

There are several IDEs that you can use to develop F# applications. Visual Studio 2015, 2017, and Visual Studio Code. Each has it's own list of pros and cons.
For this post we'll be using Visual Studio Code.

### 1) Install Visual Studio Code

Say nice things about [Visual Studio Code](https://code.visualstudio.com/). Install it. Now. Or else.

### 2) Install F# \

You might not need to do this if you have Visual Studio installed and included support for F#. But perhaps, just to be on the safe side, install the latest version based on your system from here: [F#](http://fsharp.org/)

### 3) Install the Ionide plugins

Ionide is awesome. It does cool stuff like:

- A
- B
- C

It uses another project called FORGE to do a lot of this awesome stuff. Install it using the Visual Studio Code Extensions Marketplace. 

More info: [Ionide](http://ionide.io/) plugin

These are the plugins you are looking for:

- Ionide-fsharp
- Ionide-Paket (optional)
- Ionide-FAKE (optional)

### 4) Install the Azure Functions Core Tools

This awesome command line tool let's you run your functions locally. It's not a simulation of the runtime. It **is** the runtime.
[Azure Functions Core Tools](https://www.npmjs.com/package/azure-functions-core-tools/)
We're gonna use v1.0. I tried v2.0 and didn't feel like it was ready yet. Let's blog more about that later.

```shell
npm i -g azure-functions-cli
```

### 5) Install the Azure Functions extension

Probably don't need this yet. It'll help you deploy when you're ready.

## Create your first project

Still with me? Cool! Let's make stuff!
