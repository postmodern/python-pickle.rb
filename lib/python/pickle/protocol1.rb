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

      # Opcodes for Pickle protocol version 1.
      #
      # @see https://github.com/python/cpython/blob/main/Lib/pickletools.py
      OPCODES = Protocol0::OPCODES + Set[
        41,  # EMPTY_TUPLE
        71,  # BINFLOAT
        75,  # BININT1
        84,  # BINSTRING
        85,  # SHORT_BINSTRING
        88,  # BINUNICODE
        93,  # EMPTY_LIST
        101, # APPENDS
        113, # BINPUT
        117, # SETITEMS
        125  # EMPTY_DICT
      ]

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
        when 40 # MARK
          Instructions::MARK
        when 46 # STOP
          Instructions::STOP
        when 48 # POP
          Instructions::POP
        when 50 # DUP
          Instructions::DUP
        when 70 # FLOAT
          Instructions::Float.new(read_float)
        when 73 # INT
          Instructions::Int.new(read_int)
        when 76 # LONG
          Instructions::Long.new(read_long)
        when 78 # NONE
          Instructions::NONE
        when 82 # REDUCE
          Instructions::REDUCE
        when 83 # STRING
          Instructions::String.new(read_string)
        when 86 # UNICODE
          Instructions::String.new(read_unicode_string)
        when 97 # APPEND
          Instructions::APPEND
        when 98 # BUILD
          Instructions::BUILD
        when 99 # GLOBAL
          Instructions::Global.new(read_nl_string,read_nl_string)
        when 100 # DICT
          Instructions::DICT
        when 103 # GET
          Instructions::Get.new(read_int)
        when 108 # LIST
          Instructions::LIST
        when 112 # PUT
          Instructions::Put.new(read_int)
        when 115 # SETITEM
          Instructions::SETITEM
        when 116 # TUPLE
          Instructions::TUPLE
        #
        # Protocol 1 instructions
        #
        when 41  # EMPTY_TUPLE
          Instructions::EMPTY_TUPLE
        when 71  # BINFLOAT
          Instructions::BinFloat.new(read_float64_be)
        when 75  # BININT1
          Instructions::BinInt1.new(read_uint8)
        when 84  # BINSTRING
          length = read_uint32_le
          string = @io.read(length)

          Instructions::BinString.new(length,string)
        when 85  # SHORT_BINSTRING
          length = read_uint8
          string = @io.read(length)

          Instructions::ShortBinString.new(length,string)
        when 88  # BINUNICODE
          length = read_uint32_le
          string = @io.read(length).force_encoding(Encoding::UTF_8)

          Instructions::BinUnicode.new(length,string)
        when 93  # EMPTY_LIST
          Instructions::EMPTY_LIST
        when 101 # APPENDS
          Instructions::APPENDS
        when 113 # BINPUT
          Instructions::BinPut.new(read_uint8)
        when 117 # SETITEMS
          Instructions::SETITEMS
        when 125 # EMPTY_DICT
          Instructions::EMPTY_DICT
        else
          raise(InvalidFormat,"invalid opcode (#{opcode.inspect}) for protocol 1")
        end
      end

      #
      # Reads a double precesion (64bit) floating point number, in network
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
