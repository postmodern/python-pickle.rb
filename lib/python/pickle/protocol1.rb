require 'python/pickle/protocol0'
require 'python/pickle/instructions/mark'
require 'python/pickle/instructions/empty_tuple'
require 'python/pickle/instructions/stop'
require 'python/pickle/instructions/bin_float'
require 'python/pickle/instructions/bin_int1'
require 'python/pickle/instructions/int'
require 'python/pickle/instructions/long'
require 'python/pickle/instructions/none'
require 'python/pickle/instructions/reduce'
require 'python/pickle/instructions/bin_string'
require 'python/pickle/instructions/short_bin_string'
require 'python/pickle/instructions/bin_unicode'
require 'python/pickle/instructions/global'
require 'python/pickle/instructions/empty_list'
require 'python/pickle/instructions/append'
require 'python/pickle/instructions/bin_get'
require 'python/pickle/instructions/long_bin_get'
require 'python/pickle/instructions/bin_put'
require 'python/pickle/instructions/build'
require 'python/pickle/instructions/appends'
require 'python/pickle/instructions/set_item'
require 'python/pickle/instructions/set_items'
require 'python/pickle/instructions/tuple'
require 'python/pickle/instructions/empty_dict'

module Python
  module Pickle
    #
    # Implements reading and writing of Python Pickle protocol 1.
    #
    # @api private
    #
    class Protocol1 < Protocol0

      # The `EMPTY_TUPLE` opcode.
      #
      # @since 0.2.0
      #
      # @see https://github.com/python/cpython/blob/v2.7/Lib/pickle.py#L140
      EMPTY_TUPLE = 41

      # The `BINFLOAT` opcode.
      #
      # @since 0.2.0
      #
      # @see https://github.com/python/cpython/blob/v2.7/Lib/pickle.py#L142
      BINFLOAT = 71

      # The `BININT1` opcode.
      #
      # @since 0.2.0
      #
      # @see https://github.com/python/cpython/blob/v2.7/Lib/pickle.py#L110
      BININT1 = 75

      # The `BINSTRING` opcode.
      #
      # @since 0.2.0
      #
      # @see https://github.com/python/cpython/blob/v2.7/Lib/pickle.py#L118
      BINSTRING = 84

      # The `SHORT_BINSTRING` opcode.
      #
      # @since 0.2.0
      #
      # @see https://github.com/python/cpython/blob/v2.7/Lib/pickle.py#L119
      SHORT_BINSTRING = 85

      # The `BINUNICODE` opcode.
      #
      # @since 0.2.0
      #
      # @see https://github.com/python/cpython/blob/v2.7/Lib/pickle.py#L121
      BINUNICODE = 88

      # The `EMPTY_LIST` opcode.
      #
      # @since 0.2.0
      #
      # @see https://github.com/python/cpython/blob/v2.7/Lib/pickle.py#L133
      EMPTY_LIST = 93

      # The `APPENDS` opcode.
      #
      # @since 0.2.0
      #
      # @see https://github.com/python/cpython/blob/v2.7/Lib/pickle.py#L127
      APPENDS = 101

      # The `BINGET` opcode.
      #
      # @since 0.2.0
      #
      # @see https://github.com/python/cpython/blob/v2.7/Lib/pickle.py#L138
      BINGET = 104

      # The `LONG_BINGET` opcode.
      #
      # @since 0.2.0
      #
      # @see https://github.com/python/cpython/blob/v2.7/Lib/pickle.py#L140
      LONG_BINGET = 106

      # The `BINPUT` opcode.
      #
      # @since 0.2.0
      #
      # @see https://github.com/python/cpython/blob/v2.7/Lib/pickle.py#L145
      BINPUT = 113

      # The `SETITEMS` opcode.
      #
      # @since 0.2.0
      #
      # @see https://github.com/python/cpython/blob/v2.7/Lib/pickle.py#L141
      SETITEMS = 117

      # The `EMPTY_DICT` opcode.
      #
      # @since 0.2.0
      #
      # @see https://github.com/python/cpython/blob/v2.7/Lib/pickle.py#L126
      EMPTY_DICT = 125

      #
      # Reads an instruction from the pickle stream.
      #
      # @return [Instruction]
      #   The decoded instruction.
      #
      # @raise [InvalidFormat]
      #   The pickle stream could not be parsed.
      #
      def read_instruction
        case (opcode = @io.getbyte)
        #
        # Protocol 0 instructions
        #
        when MARK
          Instructions::MARK
        when STOP
          Instructions::STOP
        when POP
          Instructions::POP
        when POP_MARK
          Instructions::POP_MARK
        when DUP
          Instructions::DUP
        when FLOAT
          Instructions::Float.new(read_float)
        when INT
          Instructions::Int.new(read_int)
        when LONG
          Instructions::Long.new(read_long)
        when NONE
          Instructions::NONE
        when REDUCE
          Instructions::REDUCE
        when STRING
          Instructions::String.new(read_string)
        when UNICODE
          Instructions::String.new(read_unicode_string)
        when APPEND
          Instructions::APPEND
        when BUILD
          Instructions::BUILD
        when GLOBAL
          Instructions::Global.new(read_nl_string,read_nl_string)
        when DICT
          Instructions::DICT
        when GET
          Instructions::Get.new(read_int)
        when LIST
          Instructions::LIST
        when PUT
          Instructions::Put.new(read_int)
        when SETITEM
          Instructions::SETITEM
        when TUPLE
          Instructions::TUPLE
        #
        # Protocol 1 instructions
        #
        when EMPTY_TUPLE
          Instructions::EMPTY_TUPLE
        when BINFLOAT
          Instructions::BinFloat.new(read_float64_be)
        when BININT1
          Instructions::BinInt1.new(read_uint8)
        when BINSTRING
          length = read_uint32_le
          string = @io.read(length)

          Instructions::BinString.new(length,string)
        when SHORT_BINSTRING
          length = read_uint8
          string = @io.read(length)

          Instructions::ShortBinString.new(length,string)
        when BINUNICODE
          length = read_uint32_le
          string = @io.read(length).force_encoding(Encoding::UTF_8)

          Instructions::BinUnicode.new(length,string)
        when EMPTY_LIST
          Instructions::EMPTY_LIST
        when APPENDS
          Instructions::APPENDS
        when BINGET
          Instructions::BinGet.new(read_uint8)
        when LONG_BINGET
          Instructions::LongBinGet.new(read_uint32_le)
        when BINPUT
          Instructions::BinPut.new(read_uint8)
        when SETITEMS
          Instructions::SETITEMS
        when EMPTY_DICT
          Instructions::EMPTY_DICT
        else
          raise(InvalidFormat,"invalid opcode (#{opcode.inspect}) for protocol 1")
        end
      end

      #
      # Reads a double precision (64bit) floating point number, in network
      # byte-order (big-endian).
      #
      # @return [Float]
      #   The decoded float.
      #
      def read_float64_be
        @io.read(8).unpack1('G')
      end

      #
      # Reads a single 8bit unsigned integer (byte).
      #
      # @return [Integer]
      #
      def read_uint8
        @io.getbyte
      end

      #
      # Reads an unsigned 32bit integer, in little-endian byte-order.
      #
      # @return [Integer]
      #
      def read_uint32_le
        @io.read(4).unpack1('L<')
      end

    end
  end
end
