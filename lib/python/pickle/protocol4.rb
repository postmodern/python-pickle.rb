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
    class Protocol4 < Protocol3

      #
      # Initializes the protocol 4 reader/writer.
      #
      def initialize(io)
        super(io)

        @io_stack = []
      end

      # Opcodes for Pickle protocol 4.
      #
      # @see https://peps.python.org/pep-3154/
      OPCODES = Protocol3::OPCODES + Set[
        140, # SHORT_BINUNICODE
        141, # BINUNICODE8
        142, # BINBYTES8
        143, # EMPTY_SET
        144, # ADDITEMS
        145, # FROZENSET
        146, # NEWOBJ_EX
        147, # STACK_GLOBAL
        148, # MEMOIZE
        149  # FRAME
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
        # Protocol 1 instructions
        #
        when 40  # MARK
          Instructions::MARK
        when 41  # EMPTY_TUPLE
          Instructions::EMPTY_TUPLE
        when 46  # STOP
          Instructions::STOP
        when 71  # BINFLOAT
          Instructions::BinFloat.new(read_float64_be)
        when 73  # INT
          Instructions::Int.new(read_int)
        when 75  # BININT1
          Instructions::BinInt1.new(read_uint8)
        when 76  # LONG
          Instructions::Long.new(read_long)
        when 78  # NONE
          Instructions::NONE
        when 82  # REDUCE
          Instructions::REDUCE
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
        when 97  # APPEND (was this deprecated?)
          Instructions::APPEND
        when 98  # BUILD
          Instructions::BUILD
        when 99  # GLOBAL
          Instructions::Global.new(read_nl_string,read_nl_string)
        when 101 # APPENDS
          Instructions::APPENDS
        when 113 # BINPUT
          Instructions::BinPut.new(read_uint8)
        when 116 # TUPLE
          Instructions::TUPLE
        when 115 # SETITEM
          Instructions::SETITEM
        when 117 # SETITEMS
          Instructions::SETITEMS
        when 125 # EMPTY_DICT
          Instructions::EMPTY_DICT
        #
        # Protocol 2 instructions
        #
        when 128 # PROT
          Instructions::Proto.new(read_uint8)
        when 129 # NEWOBJ
          Instructions::NEWOBJ
        when 130 # EXT1
          Instructions::Ext1.new(read_uint8)
        when 131 # EXT2
          Instructions::Ext2.new(read_uint16_le)
        when 132 # EXT4
          Instructions::Ext4.new(read_uint32_le)
        when 133 # TUPLE1
          Instructions::TUPLE1
        when 134 # TUPLE2
          Instructions::TUPLE2
        when 135 # TUPLE3
          Instructions::TUPLE3
        when 136 # NEWTRUE
          Instructions::NEWTRUE
        when 137 # NEWFALSE
          Instructions::NEWFALSE
        when 138 # LONG1
          length = read_uint8
          long   = read_int_le(length)

          Instructions::Long1.new(length,long)
        when 139 # LONG4
          length = read_uint32_le
          long   = read_int_le(length)

          Instructions::Long4.new(length,long)
        #
        # Protocol 3 instructions
        #
        when 66 # BINBYTES
          length = read_uint32_le
          bytes  = @io.read(length)

          Instructions::BinBytes.new(length,bytes)
        when 67 # SHORT_BINBYTES
          length = read_uint8
          bytes  = @io.read(length)

          Instructions::ShortBinBytes.new(length,bytes)
        #
        # Protocol 4 instructions
        #
        when 140 # SHORT_BINUNICODE
          length = read_uint8
          string = read_utf8_string(length)

          Instructions::ShortBinUnicode.new(length,string)
        when 141 # BINUNICODE8
          length = read_uint64_le
          string = read_utf8_string(length)

          Instructions::BinUnicode8.new(length,string)
        when 142 # BINBYTES8
          length = read_uint64_le
          bytes  = @io.read(length)

          Instructions::BinBytes8.new(length,bytes)
        when 143 # EMPTY_SET
          Instructions::EMPTY_SET
        when 144 # ADDITEMS
          Instructions::ADDITEMS
        when 145 # FROZENSET
          Instructions::FROZENSET
        when 146 # NEWOBJ_EX
          Instructions::NEWOBJ_EX
        when 147 # STACK_GLOBAL
          Instructions::STACK_GLOBAL
        when 148 # MEMOIZE
          Instructions::MEMOIZE
        when 149 # FRAME
          length = read_uint64_le

          enter_frame(read_frame(length))

          Instructions::Frame.new(length)
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

    end
  end
end
