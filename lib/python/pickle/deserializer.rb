require 'python/pickle/py_class'
require 'python/pickle/py_object'
require 'python/pickle/tuple'
require 'python/pickle/byte_array'
require 'python/pickle/exceptions'

require 'python/pickle/instructions/proto'
require 'python/pickle/instructions/frame'
require 'python/pickle/instructions/get'
require 'python/pickle/instructions/bin_get'
require 'python/pickle/instructions/long_bin_get'
require 'python/pickle/instructions/mark'
require 'python/pickle/instructions/pop_mark'
require 'python/pickle/instructions/dup'
require 'python/pickle/instructions/put'
require 'python/pickle/instructions/bin_put'
require 'python/pickle/instructions/pop'
require 'python/pickle/instructions/memoize'
require 'python/pickle/instructions/ext1'
require 'python/pickle/instructions/ext2'
require 'python/pickle/instructions/ext4'
require 'python/pickle/instructions/none'
require 'python/pickle/instructions/new_true'
require 'python/pickle/instructions/new_false'
require 'python/pickle/instructions/float'
require 'python/pickle/instructions/bin_float'
require 'python/pickle/instructions/int'
require 'python/pickle/instructions/bin_int1'
require 'python/pickle/instructions/long'
require 'python/pickle/instructions/long1'
require 'python/pickle/instructions/long4'
require 'python/pickle/instructions/bin_bytes'
require 'python/pickle/instructions/short_bin_bytes'
require 'python/pickle/instructions/bin_bytes8'
require 'python/pickle/instructions/string'
require 'python/pickle/instructions/bin_string'
require 'python/pickle/instructions/short_bin_string'
require 'python/pickle/instructions/bin_unicode'
require 'python/pickle/instructions/short_bin_unicode'
require 'python/pickle/instructions/bin_unicode8'
require 'python/pickle/instructions/byte_array8'
require 'python/pickle/instructions/empty_list'
require 'python/pickle/instructions/empty_tuple'
require 'python/pickle/instructions/tuple'
require 'python/pickle/instructions/empty_dict'
require 'python/pickle/instructions/empty_set'
require 'python/pickle/instructions/frozen_set'
require 'python/pickle/instructions/append'
require 'python/pickle/instructions/appends'
require 'python/pickle/instructions/list'
require 'python/pickle/instructions/tuple1'
require 'python/pickle/instructions/tuple2'
require 'python/pickle/instructions/tuple3'
require 'python/pickle/instructions/dict'
require 'python/pickle/instructions/global'
require 'python/pickle/instructions/stack_global'
require 'python/pickle/instructions/new_obj'
require 'python/pickle/instructions/new_obj_ex'
require 'python/pickle/instructions/reduce'
require 'python/pickle/instructions/build'
require 'python/pickle/instructions/set_item'
require 'python/pickle/instructions/set_items'
require 'python/pickle/instructions/stop'

require 'set'

module Python
  module Pickle
    #
    # Handles deserializing a stream of Python Pickle instructions.
    #
    # @api private
    #
    class Deserializer

      # The meta-stack for saving/restoring {#stack}.
      #
      # @return [Array]
      attr_reader :meta_stack

      # The object stack.
      #
      # @return [Array]
      attr_reader :stack

      # The memo dictionary.
      #
      # @return [Array]
      attr_reader :memo

      # Mapping of Python constants to Ruby classes and methods.
      #
      # @return [Hash{String => Hash{String => Class,Method}}]
      attr_reader :constants

      # Mapping of Python Pickle extension codes to Ruby objects.
      #
      # @return [Hash{Integer => Object}]
      attr_reader :extensions

      # The Python `object` class.
      OBJECT_CLASS = PyClass.new('__builtins__','object')

      #
      # Initializes the deserializer.
      #
      # @param [Hash{Integer => Object}] extensions
      #   A Hash of registered extension IDs and their Objects.
      #
      # @param [Hash{String => Hash{String => Class,Method}}] constants
      #   An optional mapping of custom Python constant names to Ruby classes
      #   or methods.
      #
      def initialize(constants: nil, extensions: nil)
        @meta_stack = []
        @stack = []
        @memo  = []

        @constants = {
          # Python 2.x
          'copy_reg' => {
            '_reconstructor' => method(:copyreg_reconstructor)
          },

          '__builtin__' => {
            'object'    => OBJECT_CLASS,
            'bytearray' => ByteArray
          },

          # Python 3.x
          'builtins' => {
            'object'    => OBJECT_CLASS,
            'bytearray' => ByteArray
          }
        }
        @constants.merge!(constants) if constants

        @extensions = {}
        @extensions.merge!(extensions) if extensions
      end

      #
      # Pushes the {#stack} onto the {#meta_stack}.
      #
      def push_meta_stack
        @meta_stack.push(@stack)
        @stack = []
      end

      #
      # Pops a previous stack off of {#meta_stack} and restores {#stack}.
      #
      # @return [Array]
      #   The current {#stack} values will be returned.
      #
      def pop_meta_stack
        items  = @stack
        @stack = (@meta_stack.pop || [])
        return items
      end

      #
      # Executes a Python Pickle instruction.
      #
      def execute(instruction)
        case instruction
        when Instructions::Proto,
             Instructions::Frame
          # no-op
        when Instructions::Get,
             Instructions::BinGet,
             Instructions::LongBinGet
          execute_get(instruction)
        when Instructions::MARK     then execute_mark
        when Instructions::POP_MARK then execute_pop_mark
        when Instructions::DUP      then execute_dup
        when Instructions::Put,
             Instructions::BinPut
          execute_put(instruction)
        when Instructions::POP     then execute_pop
        when Instructions::MEMOIZE then execute_memoize
        when Instructions::Ext1,
             Instructions::Ext2,
             Instructions::Ext4
          execute_ext(instruction)
        when Instructions::NONE     then execute_none
        when Instructions::NEWTRUE  then execute_newtrue
        when Instructions::NEWFALSE then execute_newfalse
        when Instructions::Float,
             Instructions::BinFloat,
             Instructions::Int,
             Instructions::BinInt1,
             Instructions::Long,
             Instructions::Long1,
             Instructions::Long4,
             Instructions::BinBytes,
             Instructions::ShortBinBytes,
             Instructions::BinBytes8,
             Instructions::String,
             Instructions::BinString,
             Instructions::ShortBinString,
             Instructions::BinUnicode,
             Instructions::ShortBinUnicode,
             Instructions::BinUnicode8
          @stack.push(instruction.value)
        when Instructions::ByteArray8   then execute_byte_array8(instruction)
        when Instructions::EMPTY_LIST   then execute_empty_list
        when Instructions::EMPTY_TUPLE  then execute_empty_tuple
        when Instructions::TUPLE        then execute_tuple
        when Instructions::EMPTY_DICT   then execute_empty_dict
        when Instructions::EMPTY_SET    then execute_empty_set
        when Instructions::FROZENSET    then execute_frozenset
        when Instructions::APPEND       then execute_append
        when Instructions::APPENDS      then execute_appends
        when Instructions::LIST         then execute_list
        when Instructions::TUPLE1       then execute_tuple1
        when Instructions::TUPLE2       then execute_tuple2
        when Instructions::TUPLE3       then execute_tuple3
        when Instructions::DICT         then execute_dict
        when Instructions::Global       then execute_global(instruction)
        when Instructions::STACK_GLOBAL then execute_stack_global
        when Instructions::NEWOBJ       then execute_newobj
        when Instructions::NEWOBJ_EX    then execute_newobj_ex
        when Instructions::REDUCE       then execute_reduce
        when Instructions::BUILD        then execute_build
        when Instructions::SETITEM      then execute_setitem
        when Instructions::SETITEMS     then execute_setitems
        when Instructions::STOP
          return :halt, @stack.pop
        else
          raise(NotImplementedError,"instruction is currently not fully supported: #{instruction.inspect}")
        end
      end

      #
      # Executes a `GET`, `BINGET`, or `LONG_BINGET` instruction.
      #
      # @param [Instructions::Get, Instructions::BinGet, Instructions::LongBinGet] instructions
      #   The `GET`, `BINGET`, or `LONG_BINGET` instruction.
      #
      def execute_get(instruction)
        index = instruction.value

        @stack.push(@memo[index])
      end

      #
      # Executes a `MARK` instruction.
      #
      def execute_mark
        push_meta_stack
      end

      #
      # Executes a `POP_MARK` instruction.
      #
      def execute_pop_mark
        pop_meta_stack
      end

      #
      # Executes a `DUP` instruction.
      #
      def execute_dup
        @stack.push(@stack.last)
      end

      #
      # Executes a `PUT`, `BINPUT`, or `LONG_BINPUT` instruction.
      #
      # @param [Instructions::Get, Instructions::BinGet, Instructions::LongBinGet] instructions
      #   The `PUT`, `BINPUT`, or `LONG_BINPUT` instruction.
      #
      def execute_put(instruction)
        index = instruction.value
        value = @stack.last

        @memo[index] = value
      end

      #
      # Executes the `POP` instruction.
      #
      def execute_pop
        @stack.pop
      end

      #
      # Executes the `MEMOIZE` instruction.
      #
      def execute_memoize
        @memo.push(@stack.last)
      end

      #
      # Executes a `EXT1`, `EXT2`, or `EXT4` instruction.
      #
      # @param [Instructions::Ext1, Instructions::Ext2, Instructions::Ext4] instruction
      #   The `EXT1`, `EXT2`, or `EXT4` instruction.
      #
      # @raise [DeserializationError]
      #   The execution ID was not found in {#extensions}.
      #
      def execute_ext(instruction)
        ext_id = instruction.value
        object = @extensions.fetch(ext_id) do
          raise(DeserializationError,"unknown extension ID: #{ext_id.inspect}")
        end

        @stack.push(object)
      end

      #
      # Executes a `NONE` instruction.
      #
      def execute_none
        @stack.push(nil)
      end

      #
      # Executes a `NEWTRUE` instruction.
      #
      def execute_newtrue
        @stack.push(true)
      end

      #
      # Executes a `NEWFALSE` instruction.
      #
      def execute_newfalse
        @stack.push(false)
      end

      #
      # Executes a `BYTEARRAY8` instruction.
      #
      def execute_byte_array8(instruction)
        @stack.push(ByteArray.new(instruction.value))
      end

      #
      # Executes the `EMPTY_LIST` instruction.
      #
      def execute_empty_list
        @stack.push([])
      end

      #
      # Executes the `EMPTY_TUPLE` instruction.
      #
      def execute_empty_tuple
        @stack.push(Tuple.new)
      end

      #
      # Executes a `TUPLE` instruction.
      #
      def execute_tuple
        items = Tuple.new(pop_meta_stack)
        @stack.push(items)
      end

      #
      # Executes an `EMPTY_DICT` instruction.
      #
      def execute_empty_dict
        @stack.push({})
      end

      #
      # Executes an `EMPTY_SET` instruction.
      #
      # @since 0.2.0
      #
      def execute_empty_set
        @stack.push(Set.new)
      end

      #
      # Executes a `FROZENSET` instruction.
      #
      # @since 0.2.0
      #
      def execute_frozenset
        items = pop_meta_stack

        set = Set.new(items)
        set.freeze

        @stack.push(set)
      end

      #
      # Executes an `APPEND` instruction.
      #
      def execute_append
        item = @stack.pop
        list = @stack.last

        unless list.kind_of?(Array)
          raise(DeserializationError,"cannot append element #{item.inspect} onto a non-Array: #{list.inspect}")
        end

        list.push(item)
      end

      #
      # Executes an `APPENDS` instruction.
      #
      def execute_appends
        items = pop_meta_stack
        list  = @stack.last

        unless list.kind_of?(Array)
          raise(DeserializationError,"cannot append elements #{items.inspect} onto a non-Array: #{list.inspect}")
        end

        list.concat(items)
      end

      #
      # Executes a `LIST` instruction.
      #
      def execute_list
        elements = pop_meta_stack
        @stack.push(elements)
      end

      #
      # Executes a `TUPLE1` instruction.
      #
      def execute_tuple1
        new_tuple = Tuple.new(@stack.pop(1))

        @stack.push(new_tuple)
      end

      #
      # Executes a `TUPLE2` instruction.
      #
      def execute_tuple2
        new_tuple = Tuple.new(@stack.pop(2))

        @stack.push(new_tuple)
      end

      #
      # Executes a `TUPLE3` instruction.
      #
      def execute_tuple3
        new_tuple = Tuple.new(@stack.pop(3))

        @stack.push(new_tuple)
      end

      #
      # Executes a `DICT` instruction.
      #
      def execute_dict
        pairs    = pop_meta_stack
        new_dict = {}

        until pairs.empty?
          key, value = pairs.pop(2)
          new_dict[key] = value
        end

        @stack.push(new_dict)
      end

      #
      # Implements Python's `copyreg._reconstructor` function for Python Pickle
      # protocol 0 compatibility.
      #
      # @param [PyClass, Class] class
      #   The Python or Ruby class to be initialized.
      #
      # @param [PyClass] super_class
      #   The Python super-class of the class.
      #
      # @param [Array, nil] init_arg
      #   The argument(s) that will be passed to the class'es `new` method.
      #
      def copyreg_reconstructor(klass,super_class,init_arg)
        klass.new(*init_arg)
      end

      #
      # Resolves a constant that exists in a Python namespace.
      #
      # @param [String] namespace
      #   The namespace name.
      #
      # @param [String] name
      #   The name of the constant within the namespace.
      #
      # @return [Class, PyClass, Method, nil]
      #   The resolved class or method.
      #
      def resolve_constant(namespace,name)
        constant = if (mod = @constants[namespace])
                     mod[name]
                   end

        return constant || PyClass.new(namespace,name)
      end

      #
      # Executes a `GLOBAL` instruction.
      #
      # @param [Instructions::Global] instruction
      #   The `GLOBAL` instruction.
      #
      def execute_global(instruction)
        namespace = instruction.namespace
        name      = instruction.name
        constant  = resolve_constant(namespace,name)

        @stack.push(constant)
      end

      #
      # Executes a `STACK_GLOBAL` instruction.
      #
      def execute_stack_global
        namespace, name = @stack.pop(2)
        constant = resolve_constant(namespace,name)

        @stack.push(constant)
      end

      #
      # Executes a `NEWOBJ` instruction.
      #
      def execute_newobj
        py_class, args = @stack.pop(2)
        py_object = py_class.new(*args)

        @stack.push(py_object)
      end

      #
      # Executes a `NEWOBJ_EX` instruction.
      #
      def execute_newobj_ex
        py_class, args, kwargs = @stack.pop(3)
        py_object = if kwargs
                      kwargs = kwargs.transform_keys(&:to_sym)

                      py_class.new(*args,**kwargs)
                    else
                      py_class.new(*args)
                    end

        @stack.push(py_object)
      end

      #
      # Executes a `REDUCE` instruction.
      #
      def execute_reduce
        callable, arg = @stack.pop(2)
        object = case callable
                 when PyClass, Class
                   callable.new(*arg)
                 when Method
                   callable.call(*arg)
                 else
                   raise(DeserializationError,"cannot execute REDUCE on a non-class: #{callable.inspect}")
                 end

        @stack.push(object)
      end

      #
      # Executes a `BUILD` instruction.
      #
      def execute_build
        arg    = @stack.pop
        object = @stack.last

        if object.respond_to?(:__setstate__)
          object.__setstate__(arg)
        elsif object.kind_of?(Hash)
          object.merge!(arg)
        else
          raise(DeserializationError,"cannot execute BUILD on an object that does not define a __setstate__ method or is not a Hash: #{object.inspect}")
        end
      end

      #
      # Executes a `SETITEM` instruction.
      #
      def execute_setitem
        key, value = @stack.pop(2)
        dict = @stack.last

        unless dict.kind_of?(Hash)
          raise(DeserializationError,"cannot set key (#{key.inspect}) and value (#{value.inspect}) into non-Hash: #{dict.inspect}")
        end

        dict[key] = value
      end

      #
      # Executes a `SETITEMS` instruction.
      #
      def execute_setitems
        pairs = pop_meta_stack
        dict  = @stack.last

        unless dict.kind_of?(Hash)
          raise(DeserializationError,"cannot set key value pairs (#{pairs.inspect}) into non-Hash: #{dict.inspect}")
        end

        until pairs.empty?
          key, value = pairs.pop(2)
          dict[key] = value
        end
      end

    end
  end
end
