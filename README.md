# python-pickle.rb

[![CI](https://github.com/postmodern/python-pickle.rb/actions/workflows/ruby.yml/badge.svg)](https://github.com/postmodern/python-pickle.rb/actions/workflows/ruby.yml)
[![Gem Version](https://badge.fury.io/rb/python-pickle.svg)](https://badge.fury.io/rb/python-pickle)

* [Source](https://github.com/postmodern/python-pickle.rb)
* [Issues](https://github.com/postmodern/python-pickle.rb/issues)
* [Documentation](https://rubydoc.info/gems/python-pickle)

## Description

python-pickle is a modern Ruby implementation of the Python Pickle serialization
format.

## Features

* Supports deserializing Python Pickle data into Ruby objects.
* Supports serializing Ruby objects into Python Pickle data.
* Optionally supports only parsing Python Pickle data streams for debugging
  purposes.
* Supports Pickle protocol 0, protocol 1, protocol 2, protocol 3, protocol 4,
  and protocol 5.
  * Can parse both Python 2 and Python 3 Pickled data.

## Requirements

* [Ruby] >= 3.0.0

[Ruby]: https://www.ruby-lang.org/

## Install

```shell
$ gem install python-pickle
```

### gemspec

```ruby
gem.add_dependency 'python-pickle', '~> 1.0'
```

### Gemfile

```ruby
gem 'python-pickle', '~> 1.0'
```

## Examples

Parsing and inspecting a pickle file:

```ruby
require 'python/pickle'

Python::Pickle.parse(File.open('dict.pkl'))
# => 
# [#<Python::Pickle::Instructions::Mark: MARK>,
#  #<Python::Pickle::Instructions::Dict: DICT>,
#  #<Python::Pickle::Instructions::Put: PUT 0>,
#  #<Python::Pickle::Instructions::String: STRING "foo">,
#  #<Python::Pickle::Instructions::Put: PUT 1>,
#  #<Python::Pickle::Instructions::String: STRING "bar">,
#  #<Python::Pickle::Instructions::Put: PUT 2>,
#  #<Python::Pickle::Instructions::SetItem: SETITEM>,
#  #<Python::Pickle::Instructions::Stop: STOP>]
```

## Copyright

Copyright (c) 2023 Hal Brodigan

See {file:LICENSE.txt} for details.
