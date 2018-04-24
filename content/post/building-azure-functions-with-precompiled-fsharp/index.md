+++
title = "Building Azure Functions With Precompiled F#"
abstract = "TODO"
date = 2018-04-19
tags = ['Azure', 'FSharp', 'Azure Functions', 'Visual Studio Code']
draft = true
github = "TODO"

[header]
image = "headers/high-speed-motion.jpg"
preview = true
+++

- Create a new directory
- Open VS Code
- Open the Command Pallete (`Ctrl+Shift+P`)
- Type "Azure Functions: Create New Project"
- Follow the prompts:
  - **Select the folder that will contain your function app:** Press [Enter] to pick the current folder
  - **Select a language for your function project:** Pick C#. No you didn't read that wrong. F# isn't officially support yet, so we're gonna use the C# template and just change a few things. Most of the C# template works for us because in the end it's just a precompiled app.

This creates an empty Function App initialized as a git repository. There's a `.gitignore` file tailor made for Azure Functions development. And there's a bunch of goodies in the `.vscode` folder. Let's direct our attention there for a sec.

Open up `extensions.json` and remove `ms-vscode.csharp`. That will stop VS Code from recommending we install that plugin for this project.

Open up `launch.json`. Here we find a configuration that allows us to attach a debugger to our Azure Functions process. How awesome is that? Also, if you're like me, you'll want to rename "C#" to "F#" in the `name`. Sure it's a minor detail, but those who know me know I can't live with inconsistencies like that. There, I feel better.

Open up `settings.json` and change `azureFunctions.projectLanguage` to "F#". What does this do exactly? I should look into that for you guys!
**//TODO: Look into this for those guys**

Open up `tasks.json`. There's three tasks here you can run from the VS Code Command Pallete using the `Tasks: Run Task` option: `clean`, `build`, and `Run Functions Host`. Although, you shouldn't use the Command Pallette. Use the keyboard!

- `build` can be run with `Ctrl+Shift+B` 
- `Run Functions Host` can be run with `Ctrl+Shift+R` if you [create a custom keybinding](/post/building-azure-functions-with-fsharp-and-vscode/3-running-locally/#create-a-custom-keybinding)

The `build` task depends on `clean`, so you won't really need to run `clean` on its own. And `Run Functions Host` depends on `build`. So, once you've got your custom keybinding setup, you're set with `Ctrl+Shift+R`. Boom. Done.

Alright, we're done with the `.vscode` folder. Last things last, rename the `.csproj` to `.fsproj`. Notice we're using the new project file format, and we're also rocking `netstandard2.0`. We're living on the edge here. And we're gonna pay for it.

At this point, you should be able to build the app and see a bunch of warnings in the terminal. Well, it's actually just the same warning a few times.

> warning NU1701: Package 'Microsoft.AspNet.WebApi.Client 5.2.2' was restored using '.NETFramework,Version=v4.6.1' instead of the project target framework '.NETStandard,Version=v2.0'. This package may not be fully compatible with your project.

To fix this we can reference a newer version of `Microsoft.AspNetCore.WebApi.Client`. We're going to use NuGet for this. Sorry to all the Paket fans out there, but we're not quite at the point where we need Paket yet. We'll cover Paket in a future post.

To make our lives easy, we'll once again leverage VS Code extensions. Open up the Extensions side bar and search for `NuGet Package Manager`. Install it and Reload.

Open the Command Pallete (`Ctrl+Shift+P`) and type `Nuget Package Manager: Add Package`.
Search for the package `Microsoft.NET.Sdk.Functions`. Then select the latest version. At the time of writing it's at `1.0.13`.

Now if you build again, you get no warnings.

## Create a Function

Unfortunately the Azure Functions extension can't help us here yet. There are no F# templates available for it to use. But don't worry, it's not that hard to create one from scratch.

We will use the new Attributed Model to define our function. The alternative is creating a `function.json` file ourselves to define our bindings. But this method of defining our function is being deprecated and Microsoft recommends using attributes. The attributes are kinda ugly, but alleviate the need to keep the `function.json` file in sync with your code changes.

We're going to create an `HttpTrigger` function called `HelloYou`.

Create a new file `HelloYou.fs` in the root of our app. You'll have to manually add a reference to the file in your `.fsproj`. I'm hoping that the Forge project used by the Ionide plugin gets support for the new project file format soon, because it would be a lot nicer to just run the `F#: Add Current File to Project` command. But until that fine day, add this to your `.fsproj`

```xml
  <ItemGroup>
    <Compile Include="HelloYou.fs" />
  </ItemGroup>
```

To begin, we'll have our function simply echo back "Hello".

```FSharp
namespace MyFunctions

open Microsoft.Azure.WebJobs
open Microsoft.AspNetCore.Http
open Microsoft.AspNetCore.Mvc

module HelloYou =
    [<FunctionName("HelloYou")>]
    let run ([<HttpTrigger(Extensions.Http.AuthorizationLevel.Anonymous, "get", Route = "hello")>] req: HttpRequest) =
        ContentResult(Content = "Hello", ContentType = "text/html")
```

We are nearly ready to call our function. However, as you will see after starting the Function Host, there is one annoyance we have yet to deal with. Run the `Run Functions Host` task (or press `Ctrl+Shift+R` if you created the custom keybinding).

You should see the following error:

> System.Private.CoreLib: Could not load file or assembly 'FSharp.Core, Version=4.4.3.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a'. Could not find or load a specific file.

Azure Functions doesn't much like it when you load an assembly of a newer version that it's already loaded into the runtime. In this case, it's the `FSharp.Core` assembly. I am using the latest FSharp version on my machine, so it's attempting to use `FSharp.Core, Version=4.4.3.0`. But the Azure Functions Host runtime only has `v4.2.3`. To fix this, we will explicitly install this version using NuGet. But first you need to stop the Function Host by pressing `Ctrl+C` in the terminal.

Open the Command Pallette and type `NuGet Package Manager: Add Package` and search for `FSharp.Core`. Then install version 4.2.3. You should see the new `PackageReference` in the `.fsproj`.

_NOW_ you can start the function host again and everything should be hunky dory. `Ctrl+Click` the HelloYou link <http://localhost:7071/api/hello> and your browser should open up a page that says "Hello".

## Expand the function

- Make it async
- Add logging
- Make it POST and parse some JSON out of the `req.Body`
- Add some error handle, note the need for `:> IActionResult`
- Create a `Functions.fs` file to contain the attributed functions, put the meat of the functions somewhere else
- Talk about the compiled output (the function.json files)
