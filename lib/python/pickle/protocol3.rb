require 'python/pickle/protocol2'
require 'python/pickle/instructions/bin_bytes'
require 'python/pickle/instructions/short_bin_bytes'

module Python
  module Pickle
    class Protocol3 < Protocol2
      # The `BINBYTES` opcode.
      #
      # @since 0.2.0
      #
      # @see https://github.com/python/cpython/blob/v3.10.9/Lib/pickle.py#L175
      BINBYTES = 66

      # The `SHORT_BINBYTES` opcode.
      #
      # @since 0.2.0
      #
      # @see https://github.com/python/cpython/blob/v3.10.9/Lib/pickle.py#L176
      SHORT_BINBYTES = 67

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
        #
        # Protocol 3 instructions
        #
        when BINBYTES       then read_binbytes_instruction
        when SHORT_BINBYTES then read_short_binbytes_instruction
        else
          raise(InvalidFormat,"invalid opcode (#{opcode.inspect}) for protocol 3")
        end
      end

      #
      # Reads a `BINBYTES` instruction.
      #
      # @return [Instructions::BinBytes]
      #
      # @since 0.2.0
      #
      def read_binbytes_instruction
        length = read_uint32_le
        bytes  = @io.read(length)

        Instructions::BinBytes.new(length,bytes)
      end

      #
      # Reads a `SHORT_BINBYTES` instruction.
      #
      # @return [Instructions::ShortBinBytes]
      #
      # @since 0.2.0
      #
      def read_short_binbytes_instruction
        length = read_uint8
        bytes  = @io.read(length)

        Instructions::ShortBinBytes.new(length,bytes)
      end

    end
  end
end
