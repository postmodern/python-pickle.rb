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
* Optionally supports only parsing Python Pickle data streams for debugging
  purposes.
* Supports Pickle protocol 0, protocol 1, protocol 2, protocol 3, protocol 4,
  and protocol 5.
  * Can parse both Python 2 and Python 3 Pickled data.
* Supports deserializing Python `tuple` and `bytearray` objects.
* Supports mapping Python functions to Ruby methods.
* Supports mapping Python classes to Ruby classes.

## TODO

* Add support for writing Python Pickle data.
* Add support for serializing Ruby objects to Python Pickle data.

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

Load a Python Pickle string:

```ruby
Python::Pickle.load("\x80\x04\x95\x10\x00\x00\x00\x00\x00\x00\x00}\x94\x8C\x03foo\x94\x8C\x03bar\x94s.")
# => {"foo"=>"bar"}
```

Load a Python Pickle stream:

```ruby
Python::Pickle.load(io)
# => ...
```

Loading a Python Pickle file:

```ruby
Python::Pickle.load_file('dict.pkl')
# => {"foo"=>"bar"}
```

Loading Python `bytearray` objects:

```ruby
pickle = "\x80\x05\x95\x0E\x00\x00\x00\x00\x00\x00\x00\x96\x03\x00\x00\x00\x00\x00\x00\x00ABC\x94."

Python::Pickle.load(pickle)
# => #<Python::Pickle::ByteArray: "ABC">
```

Loading Python objects:

```ruby
ickle = "\x80\x04\x95,\x00\x00\x00\x00\x00\x00\x00\x8C\b__main__\x94\x8C\aMyClass\x94\x93\x94)\x81\x94}\x94(\x8C\x01x\x94KA\x8C\x01y\x94KBub."

Python::Pickle.load(pickle)
# => 
# #<Python::Pickle::PyObject:0x00007f48c9ba7598                   
#  @attributes={"y"=>66, "x"=>65},                                
#  @init_args=[],                                                 
#  @init_kwargs={},                                               
#  @py_class=#<Python::Pickle::PyClass: __main__.MyClass>>        
```

Mapping Python classes to Ruby classes:

```ruby
class MyClass

  attr_reader :x
  attr_reader :y

  def __setstate__(attributes)
    @x = attributes['x']
    @y = attributes['y']
  end

end

pickle = "\x80\x04\x95,\x00\x00\x00\x00\x00\x00\x00\x8C\b__main__\x94\x8C\aMyClass\x94\x93\x94)\x81\x94}\x94(\x8C\x01x\x94KA\x8C\x01y\x94KBub."

Python::Pickle.load(pickle, constants: {
  '__main__' => {
    'MyClass' => MyClass
  }
})
# => #<MyClass:0x00007f48c5c28980 @x=65, @y=66>
```

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
