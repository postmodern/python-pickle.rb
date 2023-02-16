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

      # Opcodes for Pickle protocol version 2.
      #
      # @see https://github.com/python/cpython/blob/main/Lib/pickletools.py
      OPCODES = Protocol1::OPCODES + Set[
        128, # PROTO
        129, # NEWOBJ
        130, # EXT1
        131, # EXT2
        132, # EXT4
        133, # TUPLE1
        134, # TUPLE2
        135, # TUPLE3
        136, # NEWTRUE
        137, # NEWFALSE
        138, # LONG1
        139  # LONG4
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
        else
          raise(InvalidFormat,"invalid opcode (#{opcode.inspect}) for protocol 2")
        end
      end

      #
      # Reads an unisnged 16bit integer in little-endian byte-order.
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
      #   The numbero of bytes to read.
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
