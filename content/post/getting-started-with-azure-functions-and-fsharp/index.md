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

### 2) Install F#‌‌

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
npm i -g azure-functions-core-tools
```

## Create your first project

### Create Azure Resource Group

```shell
az group create --name mikesigs-whoseturnisit --location canadacentral
```

### Create Azure Storage Account

```shell
az storage account create --name mikesigsfunctionsstorage --location canadacentral --resource-group mikesigs-whoseturnisit --sku Standard_LRS
```

### Create Function App

```shell
az storage account create --name mikesigsfunctionsstorage --location canadacentral --resource-group mikesigs-whoseturnisit --sku Standard_LRS
```

## Create Function Locally

Run the `func init` command to create a directory for your project. This will create a directory
with the supplied name, and populate it with `host.json` and `local.settings.json`. It will also initialize the directory as a git repository with a `.gitignore` file.

```shell
func init WhoseTurnIsIt
```

Now open the project up in VS Code! (Do this from the CLI in two lines:

```shell
cd WhoseTurnIsIt
code .
```

### Install the Azure Functions extension

Search the Marketplace in VS Code for the Azure Functions extension. We'll be using this extension uh... extensively throughout this tutorial.

It will let us do all sorts of things. But you will immediately see the value it brings right after you install it and reload VS Code.

When you switch to the File Explorer you will see the following prompt:

![Detected Azure Functions Project Prompt](img/detected-azure-functions-project-prompt.png)

Of course you should click Yes for [a long list of reasons](https://github.com/Microsoft/vscode-azurefunctions/blob/master/docs/project.md).

Granted, it's not _as_ benefitical for an F# project, but still worth it for the `Tasks.json` alone.

### Use the Azure Storage Emulator

**DO I REALLY WANT OR NEED THIS???**

In the `local.settings.json` file, tell the Azure Web Jobs Storage and Dashboard to use the local emulator.

```json
{
  "IsEncrypted": false,
  "Values": {
    "AzureWebJobsStorage": "UseDevelopmentStorage=true",
    "AzureWebJobsDashboard": "UseDevelopmentStorage=true"
  }
}
```

### Grab the settings from Azure

Pull down the Application Settings from Azure for your function. Why? I don't know. Just do it okay...

```shell
func azure functionapp fetch-app-settings mikesigs-whoseturnisit
```

This will update your `local.settings.json` file to match the settings in Azure.

### Create Your First Function
