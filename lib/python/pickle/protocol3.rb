require 'python/pickle/protocol2'
require 'python/pickle/instructions/bin_bytes'
require 'python/pickle/instructions/short_bin_bytes'

module Python
  module Pickle
    class Protocol3 < Protocol2
      # Opcodes for Pickle protocol version 2.
      #
      # @see http://formats.kaitai.io/python_pickle/ruby.html
      OPCODES = Protocol2::OPCODES + Set[
        66, # BINBYTES
        67  # SHORT_BINBYTES
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
        when 49 # POP_MARK
          Instructions::POP_MARK
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
        when 104 # BINGET
          Instructions::BinGet.new(read_uint8)
        when 106 # LONG_BINGET
          Instructions::LongBinGet.new(read_uint32_le)
        when 113 # BINPUT
          Instructions::BinPut.new(read_uint8)
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
        else
          raise(InvalidFormat,"invalid opcode (#{opcode.inspect}) for protocol 3")
        end
      end

    end
  end
end
