+++
title = "Test"
date = 2018-03-01T14:55:10-07:00
draft = false

# Tags and categories
# For example, use `tags = []` for no tags, or the form `tags = ["A Tag", "Another Tag"]` for one or more tags.
tags = ["test"]
categories = ["test"]

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
# Heading 1

## Heading 2

### Heading 3

#### Heading 4

##### Heading 5

###### Heading 6

- Bulleted List 1
- Item 2
- Item 3

1. Numbered List 1
2. And a two
3. and a four

<!--more-->

Let's see how some inline code looks `for x = 1 {}`

And how about a code block with fences

``` c#
public class Foo {
    public int X { get; set; }

    public void Method(int p1, char p2, string p3, List<int> p3)
    {
        foreach (var x in p3) {
            Console.WriteLine($"Value is {x}");
        }
    }
}
```
