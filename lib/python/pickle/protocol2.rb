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
        when MARK     then Instructions::MARK
        when STOP     then Instructions::STOP
        when POP      then Instructions::POP
        when POP_MARK then Instructions::POP_MARK
        when DUP      then Instructions::DUP
        when FLOAT    then read_float_instruction
        when INT      then read_int_instruction
        when LONG     then read_long_instruction
        when NONE     then Instructions::NONE
        when REDUCE   then Instructions::REDUCE
        when STRING   then read_string_instruction
        when UNICODE  then read_unicode_instruction
        when APPEND   then Instructions::APPEND
        when BUILD    then Instructions::BUILD
        when GLOBAL   then read_global_instruction
        when DICT     then Instructions::DICT
        when GET      then read_get_instruction
        when LIST     then Instructions::LIST
        when PUT      then read_put_instruction
        when SETITEM  then Instructions::SETITEM
        when TUPLE    then Instructions::TUPLE
        when OBJ      then Instructions::OBJ
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
        #
        # Protocol 2 instructions
        #
        when PROTO    then read_proto_instruction
        when NEWOBJ   then Instructions::NEWOBJ
        when EXT1     then read_ext1_instruction
        when EXT2     then read_ext2_instruction
        when EXT4     then read_ext4_instruction
        when TUPLE1   then Instructions::TUPLE1
        when TUPLE2   then Instructions::TUPLE2
        when TUPLE3   then Instructions::TUPLE3
        when NEWTRUE  then Instructions::NEWTRUE
        when NEWFALSE then Instructions::NEWFALSE
        when LONG1    then read_long1_instruction
        when LONG4    then read_long4_instruction
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

      #
      # Reads a `PROTO` instruction.
      #
      # @return [Instructions::Proto]
      #
      # @since 0.2.0
      #
      def read_proto_instruction
        Instructions::Proto.new(read_uint8)
      end

      #
      # Reads a `EXT1` instruction.
      #
      # @return [Instructions::Ext1]
      #
      # @since 0.2.0
      #
      def read_ext1_instruction
        Instructions::Ext1.new(read_uint8)
      end

      #
      # Reads a `EXT2` instruction.
      #
      # @return [Instructions::Ext2]
      #
      # @since 0.2.0
      #
      def read_ext2_instruction
        Instructions::Ext2.new(read_uint16_le)
      end

      #
      # Reads a `EXT4` instruction.
      #
      # @return [Instructions::Ext4]
      #
      # @since 0.2.0
      #
      def read_ext4_instruction
        Instructions::Ext4.new(read_uint32_le)
      end

      #
      # Reads a `LONG1` instruction.
      #
      # @return [Instructions::Long1]
      #
      # @since 0.2.0
      #
      def read_long1_instruction
        length = read_uint8
        long   = read_int_le(length)

        Instructions::Long1.new(length,long)
      end

      #
      # Reads a `LONG4` instruction.
      #
      # @return [Instructions::Long4]
      #
      # @since 0.2.0
      #
      def read_long4_instruction
        length = read_uint32_le
        long   = read_int_le(length)

        Instructions::Long4.new(length,long)
      end

    end
  end
end
