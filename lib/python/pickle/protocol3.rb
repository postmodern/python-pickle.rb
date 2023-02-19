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
        #
        # Protocol 3 instructions
        #
        when BINBYTES
          length = read_uint32_le
          bytes  = @io.read(length)

          Instructions::BinBytes.new(length,bytes)
        when SHORT_BINBYTES
          length = read_uint8
          bytes  = @io.read(length)

          Instructions::ShortBinBytes.new(length,bytes)
        else
          raise(InvalidFormat,"invalid opcode (#{opcode.inspect}) for protocol 3")
        end
      end

    end
  end
end
