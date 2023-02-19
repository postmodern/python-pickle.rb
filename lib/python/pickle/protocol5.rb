require 'python/pickle/protocol4'
require 'python/pickle/instructions/byte_array8'
require 'python/pickle/instructions/next_buffer'
require 'python/pickle/instructions/readonly_buffer'

module Python
  module Pickle
    #
    # Implements Python Pickle protocol 5.
    #
    # @see https://www.python.org/dev/peps/pep-0574/
    #
    # @api private
    #
    class Protocol5 < Protocol4

      # The `BYTEARRAY8` opcode.
      #
      # @since 0.2.0
      #
      # @see https://github.com/python/cpython/blob/v2.7/Lib/pickle.py#L193
      BYTEARRAY8 = 150

      # The `NEXT_BUFFER` opcode.
      #
      # @since 0.2.0
      #
      # @see https://github.com/python/cpython/blob/v2.7/Lib/pickle.py#L194
      NEXT_BUFFER = 151

      # The `READONLY_BUFFER` opcode.
      #
      # @since 0.2.0
      #
      # @see https://github.com/python/cpython/blob/v2.7/Lib/pickle.py#L195
      READONLY_BUFFER = 152

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
        #
        # Protocol 4 instructions
        #
        when SHORT_BINUNICODE then read_short_binunicode_instruction
        when BINUNICODE8      then read_binunicode8_instruction
        when BINBYTES8        then read_binbytes8_instruction
        when EMPTY_SET        then Instructions::EMPTY_SET
        when ADDITEMS         then Instructions::ADDITEMS
        when FROZENSET        then Instructions::FROZENSET
        when NEWOBJ_EX        then Instructions::NEWOBJ_EX
        when STACK_GLOBAL     then Instructions::STACK_GLOBAL
        when MEMOIZE          then Instructions::MEMOIZE
        when FRAME            then read_frame_instruction
        #
        # Protocol 5 instructions.
        #
        when BYTEARRAY8      then read_bytearray8_instruction
        when NEXT_BUFFER     then Instructions::NEXT_BUFFER
        when READONLY_BUFFER then Instructions::READONLY_BUFFER
        else
          raise(InvalidFormat,"invalid opcode (#{opcode.inspect}) for protocol 5")
        end
      ensure
        if @io.eof? && !@io_stack.empty?
          leave_frame
        end
      end

      #
      # Reads a `BYTEARRAY8` instruction.
      #
      # @return [Instructions::ByteArray8]
      #
      # @since 0.2.0
      #
      def read_bytearray8_instruction
        length = read_uint64_le
        bytes  = @io.read(length)

        Instructions::ByteArray8.new(length,bytes)
      end

    end
  end
end
