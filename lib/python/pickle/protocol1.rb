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
    # Implements Python Pickle protocol 1.
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
        when MARK      then Instructions::MARK
        when STOP      then Instructions::STOP
        when POP       then Instructions::POP
        when POP_MARK  then Instructions::POP_MARK
        when DUP       then Instructions::DUP
        when FLOAT     then read_float_instruction
        when INT       then read_int_instruction
        when LONG      then read_long_instruction
        when NONE      then Instructions::NONE
        when REDUCE    then Instructions::REDUCE
        when STRING    then read_string_instruction
        when UNICODE   then read_unicode_instruction
        when APPEND    then Instructions::APPEND
        when BUILD     then Instructions::BUILD
        when GLOBAL    then read_global_instruction
        when DICT      then Instructions::DICT
        when GET       then read_get_instruction
        when LIST      then Instructions::LIST
        when PUT       then read_put_instruction
        when SETITEM   then Instructions::SETITEM
        when TUPLE     then Instructions::TUPLE
        when INST      then read_inst_instruction
        when OBJ       then Instructions::OBJ
        when PERSID    then read_persid_instruction
        when BINPERSID then Instructions::BINPERSID
        #
        # Protocol 1 instructions
        #
        when EMPTY_TUPLE     then Instructions::EMPTY_TUPLE
        when BINFLOAT        then read_binfloat_instruction
        when BININT1         then read_binint1_instruction
        when BINSTRING       then read_binstring_instruction
        when SHORT_BINSTRING then read_short_binstring_instruction
        when BINUNICODE      then read_binunicode_instruction
        when EMPTY_LIST      then Instructions::EMPTY_LIST
        when APPENDS         then Instructions::APPENDS
        when BINGET          then read_binget_instruction
        when LONG_BINGET     then read_long_binget_instruction
        when BINPUT          then read_binput_instruction
        when SETITEMS        then Instructions::SETITEMS
        when EMPTY_DICT      then Instructions::EMPTY_DICT
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

      #
      # Reads a `BINFLOAT` instruction.
      #
      # @return [Instructions::BinFloat]
      #
      # @since 0.2.0
      #
      def read_binfloat_instruction
        Instructions::BinFloat.new(read_float64_be)
      end

      #
      # Reads a `BININT1` instruction.
      #
      # @return [Instructions::BinInt1]
      #
      # @since 0.2.0
      #
      def read_binint1_instruction
        Instructions::BinInt1.new(read_uint8)
      end

      #
      # Reads a `BINSTRING` instruction.
      #
      # @return [Instructions::BinString]
      #
      # @since 0.2.0
      #
      def read_binstring_instruction
        length = read_uint32_le
        string = @io.read(length)

        Instructions::BinString.new(length,string)
      end

      #
      # Reads a `SHORT_BINSTRING` instruction.
      #
      # @return [Instructions::ShortBinString]
      #
      # @since 0.2.0
      #
      def read_short_binstring_instruction
        length = read_uint8
        string = @io.read(length)

        Instructions::ShortBinString.new(length,string)
      end

      #
      # Reads a `BINUNICODE` instruction.
      #
      # @return [Instructions::BinUnicode]
      #
      # @since 0.2.0
      #
      def read_binunicode_instruction
        length = read_uint32_le
        string = @io.read(length).force_encoding(Encoding::UTF_8)

        Instructions::BinUnicode.new(length,string)
      end

      #
      # Reads a `BINGET` instruction.
      #
      # @return [Instructions::BinGet]
      #
      # @since 0.2.0
      #
      def read_binget_instruction
        Instructions::BinGet.new(read_uint8)
      end

      #
      # Reads a `LONG_BINGET` instruction.
      #
      # @return [Instructions::LongBinGet]
      #
      # @since 0.2.0
      #
      def read_long_binget_instruction
        Instructions::LongBinGet.new(read_uint32_le)
      end

      #
      # Reads a `BINPUT` instruction.
      #
      # @return [Instructions::BinPut]
      #
      # @since 0.2.0
      #
      def read_binput_instruction
        Instructions::BinPut.new(read_uint8)
      end

    end
  end
end
