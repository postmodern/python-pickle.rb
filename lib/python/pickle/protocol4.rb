require 'python/pickle/protocol3'
require 'python/pickle/instructions/short_bin_unicode'
require 'python/pickle/instructions/bin_unicode8'
require 'python/pickle/instructions/bin_bytes8'
require 'python/pickle/instructions/empty_set'
require 'python/pickle/instructions/add_items'
require 'python/pickle/instructions/frozen_set'
require 'python/pickle/instructions/new_obj_ex'
require 'python/pickle/instructions/stack_global'
require 'python/pickle/instructions/memoize'
require 'python/pickle/instructions/frame'

module Python
  module Pickle
    #
    # Implements Python Pickle protocol 4.
    #
    # @see https://www.python.org/dev/peps/pep-3154/
    #
    # @api private
    #
    class Protocol4 < Protocol3

      #
      # Initializes the protocol 4 reader/writer.
      #
      def initialize(io)
        super(io)

        @io_stack = []
      end

      # The `SHORT_BINUNICODE` opcode.
      #
      # @since 0.2.0
      #
      # @see https://github.com/python/cpython/blob/v2.7/Lib/pickle.py#L180
      SHORT_BINUNICODE = 140

      # The `BINUNICODE8` opcode.
      #
      # @since 0.2.0
      #
      # @see https://github.com/python/cpython/blob/v2.7/Lib/pickle.py#L181
      BINUNICODE8 = 141

      # The `BINBYTES` opcode.
      #
      # @since 0.2.0
      #
      # @see https://github.com/python/cpython/blob/v2.7/Lib/pickle.py#L182
      BINBYTES8 = 142

      # The `EMPTY_SET` opcode.
      #
      # @since 0.2.0
      #
      # @see https://github.com/python/cpython/blob/v2.7/Lib/pickle.py#L183
      EMPTY_SET = 143

      # The `ADDITEMS` opcode.
      #
      # @since 0.2.0
      #
      # @see https://github.com/python/cpython/blob/v2.7/Lib/pickle.py#L184
      ADDITEMS = 144

      # The `FROZENSET` opcode.
      #
      # @since 0.2.0
      #
      # @see https://github.com/python/cpython/blob/v2.7/Lib/pickle.py#L185
      FROZENSET = 145

      # The `NEWOBJ_EX` opcode.
      #
      # @since 0.2.0
      #
      # @see https://github.com/python/cpython/blob/v2.7/Lib/pickle.py#L186
      NEWOBJ_EX = 146

      # The `STACK_GLOBAL` opcode.
      #
      # @since 0.2.0
      #
      # @see https://github.com/python/cpython/blob/v2.7/Lib/pickle.py#L187
      STACK_GLOBAL = 147

      # The `MEMOIZE` opcode.
      #
      # @since 0.2.0
      #
      # @see https://github.com/python/cpython/blob/v2.7/Lib/pickle.py#L188
      MEMOIZE = 148

      # The `FRAME` opcode.
      #
      # @since 0.2.0
      #
      # @see https://github.com/python/cpython/blob/v2.7/Lib/pickle.py#L189
       FRAME = 149

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
        else
          raise(InvalidFormat,"invalid opcode (#{opcode.inspect}) for protocol 4")
        end
      ensure
        if @io.eof? && !@io_stack.empty?
          leave_frame
        end
      end

      #
      # Reads an unsigned 64bit integer, in little-endian byte-order.
      #
      # @return [Integer]
      #
      def read_uint64_le
        @io.read(8).unpack1('Q<')
      end

      #
      # Reads a UTF-8 string of the desired length.
      #
      # @param [Integer] length
      #   The desired length to read.
      #
      # @return [String]
      #   The read UTF-8 string.
      #
      def read_utf8_string(length)
        @io.read(length).force_encoding(Encoding::UTF_8)
      end

      #
      # Reads a data frame of the given length.
      #
      # @param [Integer] length
      #   The desired length of the frame.
      #
      # @return [String]
      #   The read data frame.
      #
      def read_frame(length)
        @io.read(length)
      end

      #
      # Enters a new data frame.
      #
      # @param [String] frame
      #   The contents of the data frame.
      #
      def enter_frame(frame)
        @io_stack.push(@io)
        @io = StringIO.new(frame)
      end

      #
      # Leaves a data frame and restores {#io}.
      #
      def leave_frame
        @io = @io_stack.pop
      end

      #
      # Reads a `SHORT_BINUNICODE` instruction.
      #
      # @return [Instructions::ShortBinUnicode]
      #
      # @since 0.2.0
      #
      def read_short_binunicode_instruction
        length = read_uint8
        string = read_utf8_string(length)

        Instructions::ShortBinUnicode.new(length,string)
      end

      #
      # Reads a `BINUNICODE8` instruction.
      #
      # @return [Instructions::BinUnicode8]
      #
      # @since 0.2.0
      #
      def read_binunicode8_instruction
        length = read_uint64_le
        string = read_utf8_string(length)

        Instructions::BinUnicode8.new(length,string)
      end

      #
      # Reads a `BINBYTES8` instruction.
      #
      # @return [Instructions::BinBytes8]
      #
      # @since 0.2.0
      #
      def read_binbytes8_instruction
        length = read_uint64_le
        bytes  = @io.read(length)

        Instructions::BinBytes8.new(length,bytes)
      end

      #
      # Reads a `FRAME` instruction.
      #
      # @return [Instructions::Frame]
      #
      # @since 0.2.0
      #
      def read_frame_instruction
        length = read_uint64_le

        enter_frame(read_frame(length))

        Instructions::Frame.new(length)
      end

    end
  end
end
