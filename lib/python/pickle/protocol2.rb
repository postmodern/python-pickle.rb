require 'python/pickle/protocol1'
require 'python/pickle/instructions/proto'
require 'python/pickle/instructions/new_obj'
require 'python/pickle/instructions/ext1'
require 'python/pickle/instructions/ext2'
require 'python/pickle/instructions/ext4'
require 'python/pickle/instructions/tuple1'
require 'python/pickle/instructions/tuple2'
require 'python/pickle/instructions/tuple3'
require 'python/pickle/instructions/new_true'
require 'python/pickle/instructions/new_false'
require 'python/pickle/instructions/long1'
require 'python/pickle/instructions/long4'

module Python
  module Pickle
    class Protocol2 < Protocol1

      # The `PROTO` opcode.
      #
      # @since 0.2.0
      #
      # @see https://github.com/python/cpython/blob/v2.7/Lib/pickle.py#L149
      PROTO = 128

      # The `NEWOBJ` opcode.
      #
      # @since 0.2.0
      #
      # @see https://github.com/python/cpython/blob/v2.7/Lib/pickle.py#L150
      NEWOBJ = 129

      # The `EXT1` opcode.
      #
      # @since 0.2.0
      #
      # @see https://github.com/python/cpython/blob/v2.7/Lib/pickle.py#L151
      EXT1 = 130

      # The `EXT2` opcode.
      #
      # @since 0.2.0
      #
      # @see https://github.com/python/cpython/blob/v2.7/Lib/pickle.py#L152
      EXT2 = 131

      # The `EXT4` opcode.
      #
      # @since 0.2.0
      #
      # @see https://github.com/python/cpython/blob/v2.7/Lib/pickle.py#L153
      EXT4 = 132

      # The `TUPLE1` opcode.
      #
      # @since 0.2.0
      #
      # @see https://github.com/python/cpython/blob/v2.7/Lib/pickle.py#L154
      TUPLE1 = 133

      # The `TUPLE2` opcode.
      #
      # @since 0.2.0
      #
      # @see https://github.com/python/cpython/blob/v2.7/Lib/pickle.py#L155
      TUPLE2 = 134

      # The `TUPLE3` opcode.
      #
      # @since 0.2.0
      #
      # @see https://github.com/python/cpython/blob/v2.7/Lib/pickle.py#L156
      TUPLE3 = 135

      # The `NEWTRUE` opcode.
      #
      # @since 0.2.0
      #
      # @see https://github.com/python/cpython/blob/v2.7/Lib/pickle.py#L157
      NEWTRUE = 136

      # The `NEWFALSE` opcode.
      #
      # @since 0.2.0
      #
      # @see https://github.com/python/cpython/blob/v2.7/Lib/pickle.py#L158
      NEWFALSE = 137

      # The `LONG1` opcode.
      #
      # @since 0.2.0
      #
      # @see https://github.com/python/cpython/blob/v2.7/Lib/pickle.py#L159
      LONG1 = 138

      # The `LONG4` opcode.
      #
      # @since 0.2.0
      #
      # @see https://github.com/python/cpython/blob/v2.7/Lib/pickle.py#L160
      LONG4 = 139

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
        #
        # Protocol 2 instructions
        #
        when PROTO
          Instructions::Proto.new(read_uint8)
        when NEWOBJ
          Instructions::NEWOBJ
        when EXT1
          Instructions::Ext1.new(read_uint8)
        when EXT2
          Instructions::Ext2.new(read_uint16_le)
        when EXT4
          Instructions::Ext4.new(read_uint32_le)
        when TUPLE1
          Instructions::TUPLE1
        when TUPLE2
          Instructions::TUPLE2
        when TUPLE3
          Instructions::TUPLE3
        when NEWTRUE
          Instructions::NEWTRUE
        when NEWFALSE
          Instructions::NEWFALSE
        when LONG1
          length = read_uint8
          long   = read_int_le(length)

          Instructions::Long1.new(length,long)
        when LONG4
          length = read_uint32_le
          long   = read_int_le(length)

          Instructions::Long4.new(length,long)
        else
          raise(InvalidFormat,"invalid opcode (#{opcode.inspect}) for protocol 2")
        end
      end

      #
      # Reads an unsigned 16bit integer in little-endian byte-order.
      #
      # @return [Integer]
      #   The decoded integer.
      #
      def read_uint16_le
        @io.read(2).unpack1('S<')
      end

      #
      # Reads and unpacks a signed integer of arbitrary length.
      #
      # @param [Integer] length
      #   The number of bytes to read.
      #
      # @return [Integer]
      #   The decoded long integer.
      #
      def read_int_le(length)
        data = @io.read(length)

        if data.bytesize < length
          raise(InvalidFormat,"premature end of string")
        end

        return unpack_int_le(data)
      end

      #
      # Decodes a packed twos-complement long value of arbitrary length.
      #
      # @param [String] data
      #   The packed long to decode.
      #
      # @return [Integer]
      #   The unpacked long.
      #
      def unpack_int_le(data)
        return 0 if data.empty?

        long  = 0
        shift = 0

        data.each_byte do |b|
          long |= b << shift
          shift += 8
        end

        max_signed = (1 << (shift-1))

        if long >= max_signed
          long -= (1 << shift)
        end

        return long
      end

    end
  end
end
