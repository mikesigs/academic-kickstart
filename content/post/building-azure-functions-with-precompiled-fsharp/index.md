+++
title = "Building Azure Functions With Precompiled F#"
abstract = "Create a simple Azure Function using Precompiled F#, VS Code, and v2 of the Azure Functions Core Tools."
date = 2018-04-29
tags = ['Azure', 'FSharp', 'Azure Functions', 'Visual Studio Code']
draft = false
github = "https://github.com/mikesigs/building-azure-functions-with-precompiled-fsharp"

[header]
image = "headers/blue-and-pink-css-code.jpg"
preview = true
+++

Previously we looked at [Building Azure Functions with F# Script](../building-azure-functions-with-fsharp-and-vscode), which is still the only _supported_ way of creating an Azure Function with F#, but a decent option for simple functions. So, if you'd like to be safe (and stable) then that's still your best bet. However, in this post we are going to take a trip to the edge. We'll be using **.NET Core**, version 2 of the **Azure Functions Core Tools** (currently in beta), and of course **F#**. However, instead of **F# script** we'll be creating a **precompiled app**!

Being on the bleeding edge has its drawbacks however. Chances are you're going to see some bugs. The Core Tools are in beta afterall, so that should be expected. I will do my best to explain how I work around these issues, but chances are the nature of the issues I solve today will change by the time you read this.

So without further ado, let's get started!

## Setup Your Environment

You can follow the same instructions [from my previous post](../building-azure-functions-with-fsharp-and-vscode/1-setup/) to get setup, _with one exeception_. You will need to install v2 of the Azure Functions Core Tools. Also, I would recommend installing it with npm instead of Chocolatey. I had some issues when using the Chocolatey version that I never got to the bottom of.

```shell
npm i -g azure-functions-core-tools@core --unsafe-perm true
```

Also, did I say "one exception"? I meant two. You'll also need to [install the .NET Core SDK](https://www.microsoft.com/net/learn/get-started/windows#install).

Okay... _three_. Sheesh. I'm also going to use the [NuGet Package Manager](https://github.com/jmrog/vscode-nuget-package-manager) extension in Visual Studio Code, so you might as well install that now too. You could use Paket to manage the dependencies instead. It's far more popular within the F# community, but I just want to limit the number of new technologies you have to learn in these posts. I'll get to Paket one day.

## Create The Function App

Now that you have what you need, let's create our app. There is no F# template available yet, so we're going to cheat a little and use the C# template and just change a few things. So here we go...

- Create a new directory
- Open VS Code
- Open the Command Pallete (`Ctrl+Shift+P`)
- Type "Azure Functions: Create New Project"
- Follow the prompts:
  - **Select the folder that will contain your function app:** Press [Enter] to pick the current folder
  - **Select a language for your function project:** Pick C#

This creates an empty Function App initialized as a git repository. There's a `.gitignore` file tailor-made for Azure Functions development. And there's a bunch of goodies in the `.vscode` folder. Let's direct our attention there for a sec.

Inside the `.vscode` folder open up `extensions.json`. This is the file used by VS Code to recommend extensions to install for the project. Find and remove `ms-vscode.csharp`. As we aren't using C#, it's not going to be useful here.

Next, open up `launch.json`. Here we find a configuration that allows us to attach a debugger to our Azure Functions process. How awesome is that? Also, you'll want to rename **C#** to **F#** in the `name`. Sure it's a minor detail, but those who know me know I can't live with inconsistencies like that. I feel better now. Do you?

Now open `settings.json` and change `azureFunctions.projectLanguage` to `F#`. One day when F# is officially supported you'll be really happy you changed this.

And last (but certainly not least) `tasks.json`. There's three tasks in here you can run from the VS Code Command Pallete using the `Tasks: Run Task` option: **clean**, **build**, and **Run Functions Host**. But why use the Command Pallette when you can use keyboard shortcuts?

The **build** task, by default, can be run with `Ctrl+Shift+B`. While the **Run Functions Host** task will need a [custom keybinding](/post/building-azure-functions-with-fsharp-and-vscode/3-running-locally/#create-a-custom-keybinding). Follow that link to create a `Ctrl+Shift+R` shortcut to run the function. Due to the way each of these tasks depend on eachother, you'll probably use the **Run Functions Host** task the most. So it's important to make it easy.

Okay, that's it for the `vscode` folder. Last thing we want to do is rename the `.csproj` to `.fsproj`. While you're in there though, notice we're using the new project file format, as well as `netstandard2.0`.

## If You Build It, They Will... Oh

Remember when I said there'd be issues? Yeah. Here's our first one.

Build the app and you'll see a bunch of warnings in the terminal. Well actually, it's just the same warning multiple times:

> warning NU1701: Package 'Microsoft.AspNet.WebApi.Client 5.2.2' was restored using '.NETFramework,Version=v4.6.1' instead of the project target framework '.NETStandard,Version=v2.0'. This package may not be fully compatible with your project.

The fix for this is to update our version of **Microsoft.NET.Sdk.Functions**. Open the Command Pallete and invoke `Nuget Package Manager: Add Package` and search for **Microsoft.NET.Sdk.Functions**. Select the latest version, at the time of writing it's at **1.0.13**.

Now the build should finish without warnings.

## Create a Function

Unfortunately the Azure Functions extension can't help us this time. As with the project templates, there are no F# templates available yet. Also, when we changed `azureFunctions.projectLanguage` to `F#` in `settings.json`, we made it so the extension won't show us any templates. You can always set this back to C#, and then convert the C# template code to F#, but where's the fun in that? It's not that hard to create one from scratch.

We are going to use the new **Attributed Model** to define our function. This means we don't have to manage the `function.json` file anymore. It's generated at compile time based on the attributes! Full disclosure, the attributes are kinda ugly, but we'll explore a strategy to deal with that later.

We're going to create an **HttpTrigger** function called **HelloYou**, because Hello World is so last decade.

Create a new file at the root of your project called `HelloYou.fs`. You'll have to manually add a reference to the file in your `.fsproj`. I'm hoping that the Forge project used by the Ionide plugin gets support for the new project file format soon, because it would be a lot nicer to just run the `F#: Add Current File to Project` command. But until that fine day, add this to your `.fsproj`

```xml
  <ItemGroup>
    <Compile Include="HelloYou.fs" />
  </ItemGroup>
```

Add the following code to `HelloYou.fs`. We're only going to echo back "Hello" right now. It's a start.

```fsharp
namespace MyFunctions

open Microsoft.Azure.WebJobs
open Microsoft.AspNetCore.Http
open Microsoft.AspNetCore.Mvc

module HelloYou =
    [<FunctionName("HelloYou")>]
    let run ([<HttpTrigger(Extensions.Http.AuthorizationLevel.Anonymous, "get", Route = "hello")>] req: HttpRequest) =
        ContentResult(Content = "Hello", ContentType = "text/html")
```

Check out those ugly attributes. Worth it though to not have to maintain a `function.json`.

## If You Run It, They Will... Oh

I liked that heading so much I thought I'd reuse it for our second gotcha!

Run the task **Run Functions Host**. You should see the following error:

> System.Private.CoreLib: Could not load file or assembly 'FSharp.Core, Version=4.4.3.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a'. Could not find or load a specific file.

This is caused by an assembly version mismatch in the Azure Functions Core Tools runtime. In this case, it's the `FSharp.Core` assembly. Like you, I am using the latest FSharp version on my machine, so our app is attempting to load `FSharp.Core, Version=4.4.3.0`. But the Azure Functions runtime has already loaded `v4.2.3`. To fix this, we will explicitly install version `v4.2.3` using NuGet. 

Stop the Function Host if it's still running (press `Ctrl+C` in the terminal). Then open the Command Pallette and invoke `NuGet Package Manager: Add Package` and find `FSharp.Core`. Install version 4.2.3. Once complete you should see a new `PackageReference` in the `.fsproj` for `FSharp.Core`.

## If You Run It, It Will... Run

Okay, _NOW_ you can start the function host and everything should be just hunky dory. If you `Ctrl+Click` the HelloYou link <http://localhost:7071/api/hello> in the terminal window your browser should open up a page that says "Hello".

Amazing! We are real programmers with our "Hello" string. But we can do better...

## Let's Deal With Those Attributes

I think I read somewhere that it's a good practice to keep the attributed function declarations separate from your actual code. But in case I'm imagining that, then you can say you read it here first.

Let's create a `Functions.fs` file at the root of our project and put our attributed function there. Don't forget to update the `.fsproj`.

### Functions.fs

```fsharp
namespace MyFunctions

open Microsoft.Azure.WebJobs
open Microsoft.AspNetCore.Http

module Functions =

    [<FunctionName("HelloYou")>]
    let helloYou ([<HttpTrigger(Extensions.Http.AuthorizationLevel.Anonymous, "get", Route = "hello")>] req: HttpRequest) 
        = HelloYou.run req
```

### fsproj

The ordering here is important!

```xml
  <ItemGroup>
    <Compile Include="HelloYou.fs"/>
    <Compile Include="Functions.fs"/>
  </ItemGroup>
```

### HelloYou.fs

```fsharp
namespace MyFunctions

open Microsoft.AspNetCore.Http
open Microsoft.AspNetCore.Mvc

module HelloYou =
    let run (req: HttpRequest) =
        ContentResult(Content = "Hello", ContentType = "text/html")
```

Now that the Azure Functions stuff is separated, we are free to write more canonical F# in our `HelloYou.fs`.
Make sure you run the function again to make sure it still works.

## This Isn't Even My Final Form

Now that we've got things running, and we've shunted our attributes to a separate file, let's fill out the rest of our function!

We're going to add some logging, so we have to add a `log: TraceWriter` to our function declration, and we're also going to change the HTTP method from GET to POST. 

Our `Functions.fs` now looks like this:

```fsharp
namespace MyFunctions

open Microsoft.Azure.WebJobs
open Microsoft.AspNetCore.Http
open Microsoft.Azure.WebJobs.Host

module Functions =

    [<FunctionName("HelloYou")>]
    let helloYou
        (
            [<HttpTrigger(Extensions.Http.AuthorizationLevel.Anonymous, "post", Route = "hello")>] req: HttpRequest,
            log: TraceWriter
        )
        = HelloYou.run req log
```

For the `HelloYou.run` function itself we're going to make a number of changes:

First of all, we're going to add the ability to take some input JSON. To manage this we need to define a type for deserialization: `InputModel`. We'll then read the `req.Body` using a `StreamReader`, and deserialize the input with `JsonConvert.DeserializeObject`. 

Then we do some quick validation of the input to ensure both **FirstName** and **LastName** are provided. Based on this check we'll either return a `BadRequestObjectResult` or an `OkObjectResult`. Take note that we have to cast these response types to `IActionResult` in order to appease the F# compiler. 

We've also added some logging, and wrapped the whole thing in an async workflow.

Our `HelloYou.fs` now looks ~~a little something like~~ exactly like this:

```fsharp
namespace MyFunctions

open Microsoft.AspNetCore.Http
open Microsoft.AspNetCore.Mvc
open Microsoft.Azure.WebJobs.Host
open System.IO
open Newtonsoft.Json
open System

module HelloYou =
    type InputModel = {
        FirstName: string
        LastName: string
    }

    exception InvalidInputException of string

    let run (req: HttpRequest) (log: TraceWriter) =
        log.Info "[Enter] HelloYou.run"
        async {
            use stream = new StreamReader(req.Body)
            let! body = stream.ReadToEndAsync() |> Async.AwaitTask
            let input = JsonConvert.DeserializeObject<InputModel>(body)
            if (String.IsNullOrWhiteSpace input.FirstName) || (String.IsNullOrWhiteSpace input.LastName) then
                log.Info "Received by input"
                return BadRequestObjectResult "Please pass a JSON object with a FirstName and a LastName." :> IActionResult
            else
                log.Info "Received good input"
                return OkObjectResult (sprintf "Hello, %s %s" input.FirstName input.LastName) :> IActionResult
        }
        |> Async.RunSynchronously
```

You should be able to run this locally now and test it with Postman. Here's what a good request looks like:

![Postman Request](img/postman-request.png)

Notice, there is no error handling. So if you pass some invalid input you'll get a **500 Internal Server Error** back.

## What About the `function.json`

Without the function attributes we would have had to create a `function.json` file ourselves. Fortunately, this gets generated for us at compile time. The generated file is located  at `bin\Debug\netstandard2.0\HelloYou\function.json` and looks like this:

```json
{
  "generatedBy": "Microsoft.NET.Sdk.Functions-1.0.13",
  "configurationSource": "attributes",
  "bindings": [
    {
      "type": "httpTrigger",
      "route": "hello",
      "methods": [
        "post"
      ],
      "authLevel": "anonymous",
      "name": "req"
    }
  ],
  "disabled": false,
  "scriptFile": "../bin/building-azure-functions-with-precompiled-fsharp.dll",
  "entryPoint": "MyFunctions.Functions.helloYou"
}
```

Notice that it indicates it's a generated file with the `generatedBy` property. And check out the bindings. You can see in the `req` binding it lists the only method supported is "post", and the `authLevel` we specified is set to "anonymous". Two properties essential to our precompiled app are listed at the end. The `scriptFile` and `entryPoint`. These point to the compiled assembly, and the `[namespace].[module].[function]` of our starting function in `Functions.fs`.

## What's Next

We covered a ton of ground on this one! Working with Pre-Compiled apps gives us a ton of flexibility. Also, we didn't need that weird [Editor Prelude](../building-azure-functions-with-fsharp-and-vscode/2-create-function-app/#holy-squigglies) thing. But we did lose that slick auto-reload on changes thing you can do with F# (and C#) Script. The good news is, that's been implemented already and will likely be included in the next beta release of the core tools!

Next up you could try switching from NuGet to Paket. Or maybe you want to use FAKE to build and run your project. Or better yet, try some different bindings. Cosmos is really cool!

You can try deploying this to your Azure account, following the instructions [here](../building-azure-functions-with-fsharp-and-vscode/4-deploy-to-azure/).

Oh, and try attaching the debugger to your function! Just run the function, set a breakpoint, and press `F5`!

That's it for now. And thanks for reading!