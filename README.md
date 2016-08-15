# cinch-commands

* [Original Source](https://github.com/postmodern/cinch-commands)
* [Issues](https://github.com/postmodern/cinch-commands/issues)
* [Documentation](http://rubydoc.info/gems/cinch-commands/frames)

## Description

Allows defining multiple commands within a Cinch Plugin.

## Features

* Argument types.
* `!help` command with detailed output:
  * Usages
  * Summaries
  * Descriptions

## Examples

    require 'cinch/commands'

    class MyPlugin

      include Cinch::Plugin
      include Cinch::Commands

      command :foo,
              [{name: "arg1", format: :string, optional: false},
               {name: "arg2", format: :integer, optional: false}],
              summary:     "Does foo",
              description: "example"\
              " more info as well"

      command :bar, [{ name: "NAME", format: :string, optional: false}],
              aliases: [:b]

      def foo(m,arg1,arg2)
      end

      def bar(m,name)
      end

    end

## Requirements

* [cinch][1] ~> 2.0

## Install

    $ gem install cinch-commands

## Copyright

Copyright (c) 2012-2013 Hal Brodigan

See {file:LICENSE.txt} for details.

[1]: https://github.com/cinchrb/cinch#readme
