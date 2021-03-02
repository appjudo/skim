Skim [ ![Build status](https://travis-ci.org/appjudo/skim.png) ](https://travis-ci.org/appjudo/skim)
====

Take the fat out of your client-side templates with Skim. Skim is the [Slim](http://slim-lang.com/) templating engine
with embedded CoffeeScript. It compiles to JavaScript templates (`.jst`), which can then be served by Rails or any other
Sprockets-based asset pipeline.

# Install

`gem install skim`, or add `skim` to your `Gemfile`.

# Usage

Create template files with the extension
`.jst.skim`. For example, `test.jst.skim`:

```jade
p Hello #{@world}!
```

In your JavaScript or CoffeeScript, render the result, passing a context object:

```js
$("body").html(JST["test"]({world: "World"}));
```

## Command Line Interface

The CLI allows Skim to be used in Gulp and Grunt workflows, extending the reach of Skim from the Ruby world into the JS/ES/CoffeeScript communities.

Features:
- Options to output Skim asset and templates separately.
- Options to assign template function to `module.exports`, a global function variable, or a global object (keyed by filename, as Sprockets does with its `JST` object).

Usage: `skim [options]`

```
-s, --stdin                      Read input from standard input instead of an input file
-e, --export                     Assign to module.exports for CommonJS require
-n, --node-global                Use Node.js global object for global assignments
    --jst                        Assign to global JST object keyed by truncated filename
    --assign variableName        Assign to a global variable
    --assign-object objectName   Assign to a global object keyed by truncated filename
    --asset-only                 Output only the Skim preamble asset
    --omit-asset                 Omit Skim preamble asset from output
    --trace                      Show a full traceback on error
-o, --option name=code           Set skim option
-r, --require library            Load library or plugin
-h, --help                       Show this help message
-v, --version                    Print version number
```

# Caveats

Skim is an early proof-of-concept. Some Slim features are still missing:

* Skim does not currently support embedded engines. Being a client-side templating languages, it will only be able to support embedded engines with a client-side implementation.
* Skim does not currently support HTML pretty-printing (Slim's `:pretty` option). This is low priority, as pretty-printing is even less important client-side than server-side.
* Skim does not currently support backslash line continuations.

# Language reference

Skim supports the following Slim language features:

* doctype declarations (`doctype`)
* HTML Comments (`/!`) and conditional comments (`/[...]`)
* static content (same line and nested)
* dynamic content, escaped and not (`=` and `==`)
* control logic (`-`)
* string interpolation, escaped and not (`#{}` and `#{{}}`)
* id and class attribute shortcuts (`#` and `.`)
* attribute and attribute value wrappers
* logic-less (sections) mode

Several Coffee/JavaScript considerations are specific to Skim:

* When interpolating the results of evaluating code, Skim will replace `null` and `undefined` results with an empty
string.
* You will typically want to use the fat arrow `=>` function definition to create callbacks, to preserve the binding of
`this` analogously to how `self` behaves in a Ruby block.

## The Context Object

The context object you pass to the compiled template function becomes the value of this inside your template. You can
use CoffeeScript's `@` sigil to easily access properties and call helper methods on the context object.

## Escaping and Unescaping

Like Slim, Skim escapes dynamic output by default, and it supports the same `==` and `#{{}}` syntaxes for bypassing
escaping. In addition, the special `safe` method on the context object tells Skim that the string can be output without
being escaped. You can use this in conjunction with `escape` context method to selectively sanitize parts of the string.

For example, given the template:

```jade
= @linkTo(@project)
```

you could render it with the following context:

```coffeescript
JST["my_template"]
  project: { id: 4, name: "Crate & Barrel" }
  linkTo: (project) ->
    url  = "/projects/#{project.id}"
    name = @escape project.name
    @safe "<a href='#{url}'>#{name}</a>"
```

to produce:

```html
<a href='/projects/4'>Crate &amp; Barrel</a>
```

## The Skim Asset

By default, all you need to do to start using Skim is add it to your Gemfile. Skim will embed a small amount of
supporting code in each generated template asset. You can remove this duplication by manually including Skim's asset,
and setting Skim's `:use_asset` option to true.

In Rails, this can be done by adding the following to `application.js`:

```js
//= require skim
```

And the following in an initializer:

```ruby
Skim::Engine.default_options[:use_asset] = true
```

Skim templates also support dependency injection for the Skim asset, instead of using a global Skim variable. Example in Node.js:

```js
var Skim = require('./skim_asset_module.js')
var template = require('./template_module.js');
console.log(template({Skim: Skim, first_name: 'Dave', last_name: 'Smith'}));
```

# License (MIT)

Copyright (c) 2012 John Firebaugh, (c) 2015 AppJudo Inc.

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# Special Thanks

* John Firebaugh, for creating Skim
* Andrew Stone, for Slim
* Magnus Holm, for Temple
* Daniel Mendler, for maintenance of Slim and Temple
