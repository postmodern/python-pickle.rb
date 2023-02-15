require 'python/pickle/protocol'
require 'python/pickle/instructions/mark'
require 'python/pickle/instructions/dict'
require 'python/pickle/instructions/string'
require 'python/pickle/instructions/put'
require 'python/pickle/instructions/get'
require 'python/pickle/instructions/int'
require 'python/pickle/instructions/long'
require 'python/pickle/instructions/set_item'
require 'python/pickle/instructions/tuple'
require 'python/pickle/instructions/list'
require 'python/pickle/instructions/none'
require 'python/pickle/instructions/append'
require 'python/pickle/instructions/pop'
require 'python/pickle/instructions/dup'
require 'python/pickle/instructions/stop'
require 'python/pickle/exceptions'

require 'set'

module Python
  module Pickle
    #
    # Implements reading and writing of Python Pickle protocol 0.
    #
    # @api private
    #
    class Protocol0 < Protocol

      # Opcodes for Pickle protocol version 0.
      #
      # @see https://github.com/python/cpython/blob/main/Lib/pickletools.py
      OPCODES = Set[
        40,  # MARK
        46,  # STOP
        48,  # POP
        50,  # DUP
        73,  # INT
        76,  # LONG
        78,  # NONE
        83,  # STRING
        86,  # UNICODE
        97,  # APPEND
        100, # DICT
        103, # GET
        108, # LIST
        112, # PUT
        115, # SETITEM
        116  # TUPLE
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
        when 40 # MARK
          Instructions::MARK
        when 100 # DICT
          Instructions::DICT
        when 83 # STRING
          Instructions::String.new(read_string)
        when 86 # UNICODE
          Instructions::String.new(read_unicode_string)
        when 112 # PUT
          Instructions::Put.new(read_int)
        when 103 # GET
          Instructions::Get.new(read_int)
        when 73 # INT
          Instructions::Int.new(read_int)
        when 76 # LONG
          Instructions::Long.new(read_long)
        when 115 # SETITEM
          Instructions::SETITEM
        when 116 # TUPLE
          Instructions::TUPLE
        when 108 # LIST
          Instructions::LIST
        when 78 # NONE
          Instructions::NONE
        when 97 # APPEND
          Instructions::APPEND
        when 48 # POP
          Instructions::POP
        when 50 # DUP
          Instructions::DUP
        when 46 # STOP
          Instructions::STOP
        else
          raise(InvalidFormat,"invalid opcode (#{opcode.inspect}) for protocol 0")
        end
      end

      #
      # Reads a hex number from the pickle stream.
      #
      # @param [Integer] digits
      #   The number of digits to read.
      #
      # @return [String]
      #   The decoed raw character.
      #
      def read_hex_escaped_char
        string = @io.read(2)

        unless string =~ /\A[0-9a-fA-F]{2}\z/
          bad_hex = string.inspect[1..-2]

          raise(InvalidFormat,"invalid hex escape character: \"\\x#{bad_hex}\"")
        end

        return string.to_i(16).chr
      end

      #
      # Reads an escaped character from the pickle stream.
      #
      # @return [String]
      #   The unescaped raw character.
      #
      def read_escaped_char
        case (letter = @io.getc)
        when 'x'  then  read_hex_escaped_char
        when 't'  then "\t"
        when 'n'  then "\n"
        when 'r'  then "\r"
        when '\\' then '\\'
        when "'"  then "'"
        else
          bad_escape = letter.inspect[1..-2]

          raise(InvalidFormat,"invalid backslash escape character: \"\\#{bad_escape}\"")
        end
      end

      #
      # Reads an ASCII string from the pickle stream.
      #
      # @return [String]
      #   The decoded raw string.
      #
      def read_string
        new_string = String.new(encoding: Encoding::ASCII_8BIT)

        unless @io.getc == "'"
          raise(InvalidFormat,"cannot find beginning single-quote of string")
        end

        until @io.eof?
          case (char = @io.getc)
          when "\\"
            new_string << read_escaped_char
          when "'" # end-of-string
            break
          else
            new_string << char
          end
        end

        newline = @io.getc

        if newline == nil
          raise(InvalidFormat,"unexpected end of stream after the end of a single-quoted string")
        elsif newline != "\n"
          raise(InvalidFormat,"expected a '\\n' character following the string, but was #{newline.inspect}")
        end

        return new_string
      end

      #
      # Reads a short unicode escaped character.
      #
      # @return [String]
      #   The decoed UTF-8 character.
      #
      # @raise [InvalidFormat]
      #   The unicode escaped character was invalid.
      #
      def read_unicode_escaped_char16
        string = @io.read(4)

        unless string =~ /\A[0-9a-fA-F]{4}\z/
          bad_unicode = string.inspect[1..-2]

          raise(InvalidFormat,"invalid unicode escape character: \"\\u#{bad_unicode}\"")
        end

        return string.to_i(16).chr(Encoding::UTF_8)
      end

      #
      # Reads a long unicode escaped character.
      #
      # @return [String]
      #   The decoed UTF-8 character.
      #
      # @raise [InvalidFormat]
      #   The unicode escaped character was invalid.
      #
      def read_unicode_escaped_char32
        string = @io.read(8)

        unless string =~ /\A[0-9a-fA-F]{8}\z/
          bad_unicode = string.inspect[1..-2]

          raise(InvalidFormat,"invalid unicode escape character: \"\\U#{bad_unicode}\"")
        end

        return string.to_i(16).chr(Encoding::UTF_8)
      end

      #
      # Reads a unicode escaped character from the pickle stream.
      #
      # @return [String]
      #   The unescaped raw unicode character.
      #
      def read_unicode_escaped_char
        case (letter = @io.getc)
        when 'x'  then read_hex_escaped_char
        when 'u'  then read_unicode_escaped_char16
        when 'U'  then read_unicode_escaped_char32
        when "\\" then "\\"
        else
          bad_escape = letter.inspect[1..-2]

          raise(InvalidFormat,"invalid unicode escape character: \"\\#{bad_escape}\"")
        end
      end

      #
      # Reads a unicode String from the pickle stream.
      #
      # @return [String]
      #   The decoded raw unicode String.
      #
      def read_unicode_string
        new_string = String.new(encoding: Encoding::UTF_8)

        until @io.eof?
          case (char = @io.getc)
          when "\\" # backslash escaped character
            new_string << read_unicode_escaped_char
          when "\n" # end-of-string
            return new_string
          else
            new_string << char
          end
        end

        raise(InvalidFormat,"unexpected end of stream while parsing unicode string: #{new_string.inspect}")
      end

      #
      # Reads an integer from the pickle stream.
      #
      # @return [Integer, true, false]
      #   The decoded Integer.
      #   If the integer is `00`, then `false` will be returned.
      #   If the integer is `01`, then `true` will be returned.
      #
      def read_int
        new_string = String.new

        until @io.eof?
          case (char = @io.getc)
          when /[0-9]/
            new_string << char
          when "\n" # end-of-integer
            return case new_string
                   when '00' then false
                   when '01' then true
                   else           new_string.to_i
                   end
          else
            raise(InvalidFormat,"encountered a non-numeric character while reading an integer: #{char.inspect}")
          end
        end

        raise(InvalidFormat,"unexpected end of stream while parsing an integer: #{new_string.inspect}")
      end

      #
      # Reads a long integer.
      #
      # @return [Integer]
      #   The decoded Integer.
      #
      # @raise [InvalidFormat]
      #   Encountered a non-numeric character or a premature end of the stream.
      #
      def read_long
        new_string = String.new

        until @io.eof?
          case (char = @io.getc)
          when /[0-9]/
            new_string << char
          when 'L'
            newline = @io.getc

            if newline == nil
              raise(InvalidFormat,"unexpected end of stream after the end of an integer")
            elsif newline != "\n"
              raise(InvalidFormat,"expected a '\\n' character following the integer, but was #{newline.inspect}")
            end

            return new_string.to_i
          else
            raise(InvalidFormat,"encountered a non-numeric character while reading a long integer: #{char.inspect}")
          end
        end

        raise(InvalidFormat,"unexpected end of stream while parsing a long integer: #{new_string.inspect}")
      end

    end
  end
end
