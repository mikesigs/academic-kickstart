+++
title = "Have Your Cake and Build It Too"
abstract = "Create a simple Cake build script with Visual Studio Code and .NET Core"
date = 2018-09-25
draft = true

tags = ['Visual Studio Code', 'Cake', '.NET Core']
github = "https://github.com/mikesigs/have-your-cake-and-build-it-too"

[header]
image = "headers/cake.jpg"
preview = true
+++

In this post I will walk you through the basics of using the fantastic Cake build tool to build, test, and package a .NET Core Web API application.

## Create Project Directory

Let's start with the absolute basics and create a new folder for our code. I'm going to put mine under `c:\code`, but you do you.

```console
> md c:\code\HaveYourCakeAndBuildItToo
```

## Open VS Code

Now navigate into that directory and open VS Code.

```console
> cd c:\code\HaveYourCakeAndBuildItToo
> code .
```

## Install the Cake extension

There is a fantastic extension available for Visual Studio Code which makes working with Cake a piece of, well... cake. Sorry for the pun, but it's true! You get a bunch of commands which make bootstrapping your build scripts dead easy! There's a bunch of helpful code snippets, Intellisense Support, and \*gasp\* ... **Debugging Support**! Yeah, you can friggin' debug your build scripts. I love that!

So without further ado, open the Extensions sidebar (`Ctrl+Shift+X`) and search for [Cake](https://github.com/cake-build/cake-vscode).

## Setup Your Workspace

To get your project setup quickly the Cake extension provides a single command that does just about all you need.

Open the Command Palette (`Ctrl+Shift+P`) and run the command `Cake: Install to workspace`.

This will:

- Install the Cake binaries into the `./tools` folder
- Create two bootstrappers in the root: `build.ps1` and `build.sh`
- Create your Cake build file `build.cake`

The one thing that doesn't appear to be included in this command is the Intellisense support. But that's simple enough to fix. Just open the Command Palette again and run `Cake: Install intellisense support`. This will install the `Cake.Bakery` NuGet package into the `./tools` folder providing you with a first class development experience when writing your build scripts. How awesome is that?

### Ignore the Tools Folder

Silly me. I'm getting too excited. Let's simmer it down a bit and do something boring (but necessary).

We don't want to commit any of the binaries in the `./tools` folder to our code repository. But the bootstrapper will need the `packages.config` in there. If you are using Git, you can add the following to a `.gitignore` file to omit everything in the `./tools` folder except the `packages.config`.

While we're at it, we'll also go ahead and ignore the `./build` folder which we'll see later on.

```sh
# Build related
tools/**
!tools/packages.config
build/**
```

## The Cake File

The `build.cake` file is where you will define your build steps. The `Install to workspace` command created this file with a basic starting point including some helpful arguments, setup and teardown methods, and a default task.

### Arguments

Arguments are specified on the command line when invoking the build script. The template starts you with the two most common arguments: _target_ and _configuration_.

Usage:

```console
> .\build.ps1 -target Build -configuration Debug
```

### Setup and Teardown

The Setup and Teardown methods will run before and after all tasks, respectively. I haven't really found a use for them yet, so feel free to remove them for now.

### Default Task

The default task is just a starting point. You can rename this tasks to something else, give it some actual functionality, or just use it as a pointer to another tasks using `.IsDependentOn("OtherTask")`

## Application Code

Of course, we're going to need some kind of application to build!

First, let's add a solution file at the root of our project. This will simplify our build step, as we can specify the `.sln` file instead of listing each of the `.csproj` files one by one:

```console
> dotnet new sln
```

Next we'll add a `src` folder to contain all of our projects and within it we'll create a Web API project called `HaveYourApi`. Finally, we'll add the API project to our `.sln` file:

```console
> md .\src
> dotnet new webapi -n HaveYourApi -o .\src\HaveYourApi
> dotnet sln add .\src\HaveYourApi
```

## Create the Build Task

Now that we have a project and a solution to build, let's add a build step.

Open `build.cake` and add the following code _(I like to add my tasks just before the `Default` task, but you can put it anywhere you like)_:

```cs
Task("Build")
    .Does(() =>
    {
        DotNetCoreBuild("HaveYourCakeAndBuildItToo.sln", new DotNetCoreBuildSettings {
            Configuration = configuration
        });
    });
```

Notice in Visual Studio Code the `run task|debug task` links above each of our tasks. You can click these to quickly build or debug your build script starting with that task, without typing a thing on the command line. Pretty neat-o!

Go ahead and click `run task` and watch the build output in the VS Code terminal.

## Create a UnitTests Task

A very common task to have in a build script is one which runs one or more Unit Test projects after the `Build` step completes. So let's do that!

First, we'll add an xUnit project then add it to the solution file.

```console
> dotnet new xunit -n HaveYourApi.Test -o .\src\HaveYourApi.Test
> dotnet sln add .\src\HaveYourApi.Test
```

Following the convention of using a `.Test` suffix for you test projects will make it easy to match all of your test projects using a pattern in your `UnitTests` task.

Let's create that `UnitTests` task now. We will do a couple of new things here:

- First, we'll use the `IsDependentOn("Build")` method to tell Cake to run the `Build` task
- Then we'll use `DoesForEach()` instead of `Does`, and pass it the list of `.csproj` files for all the `*.Test` projects in the solution
- Finally, since we're already depending on the `Build` task, we can tell the `dotnet` command to not bother building again

```cs
Task("UnitTests")
    .IsDependentOn("Build")
    .DoesForEach(GetFiles("./src/**/*.Test.csproj"), (project) => {
        DotNetCoreTest(project.FullPath, new DotNetCoreTestSettings {
            Configuration = configuration,
            NoBuild = true
        });
    });
```

## Octopus Deploy

I use Octopus Deploy at work. And Cake makes it really easy to automate all sorts of things with Octopus. We're going to keep things simple here and just create an Octopus-friendly NuGet package that we can use in an Octopus deployment.

In order to create the NuGet package for Octopus we should use `OctoPack`. But to do this in our build script we need the `Octo.exe` command line tool. Often people will download this binary and commit it right to their repository. But Cake provides us with a couple of ways to avoid doing that, and instead get the tool at runtime from NuGet.

### Option 1: Using the Bootstrapper and packages.config

The recommended way to install a tool is to add a reference to it in the `./tools/packages.config`. For OctopusTools this might look like:

```xml
<package id="OctopusTools" version="4.41" />
```

When we run the bootstrapper (e.g. `build.ps1`) it will install any tools it finds in the `./tools/packages.config`.

### Option 2: Using the `#tool` directive

Cake extends the C# language with a few custom pre-processor directives. In this case, we are interested in the `#tool` directive which will download a tool from NuGet and install it in the `.\tools` folder.

For OctopusTools, we'd need to add the following line to the top of our `build.cake` file:

```cs
#tool nuget:?package=OctopusTools
```

The VS Code Cake extension makes this even easier as it will provide a quick way to search the available tools on NuGet and even let you pick a specific version.

### Install the Tool

Pick one of the above 2 options to add the `OctopusTools` uh... tools. I kind of prefer Option 2 because it makes it explicit in your build file what tools you are depending on.

### Create An OctoPack Task

Now that we know we'll have `Octo.exe` at our disposal, let's create the necessary task to create the package.

OctoPack doesn't support ASP.NET Core projects directly yet. But the workaround is simple enough. First you have to publish your MVC project using `dotnet publish` and then you can run OctoPack on the published files. 

We will publish the `HaveYourApi` project into `./build/publish` and then pack those files as a NuGet package into the `./build/pack` folder.

```cs
Task("OctoPack")
    .IsDependentOn("UnitTests")
    .Does(() => {
        DotNetCorePublish("./src/HaveYourApi/HaveYourApi.csproj", new DotNetCorePublishSettings {
            Configuration = configuration,
            NoBuild = true,
            OutputDirectory = "./build/publish"
        });
        OctoPack("HaveYourApi", new OctoPackSettings {
            BasePath = "./build/publish",
            OutFolder = "./build/pack"
        });
    });
```

## Conclusion

Your next steps would be to publish your NuGet package somewhere Octopus can find it and configure your deployment. But that is well beyond the scope of this article.

I hope you found this helpful, and got at least a little bit excited about how easy it is to work with Cake in Visual Studio Code. If you're coming from an existing tool like psake or FAKE, I think you'll find a lot of compelling reasons to switch to Cake, like great Intellisense support, built-in snippets, and the awesome debugging capability.

Okay, that's all for now. Go have some Cake!
