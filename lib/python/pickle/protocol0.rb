require 'python/pickle/protocol'
require 'python/pickle/instructions/mark'
require 'python/pickle/instructions/dict'
require 'python/pickle/instructions/string'
require 'python/pickle/instructions/put'
require 'python/pickle/instructions/get'
require 'python/pickle/instructions/float'
require 'python/pickle/instructions/int'
require 'python/pickle/instructions/long'
require 'python/pickle/instructions/set_item'
require 'python/pickle/instructions/tuple'
require 'python/pickle/instructions/list'
require 'python/pickle/instructions/none'
require 'python/pickle/instructions/append'
require 'python/pickle/instructions/global'
require 'python/pickle/instructions/reduce'
require 'python/pickle/instructions/build'
require 'python/pickle/instructions/pop'
require 'python/pickle/instructions/pop_mark'
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

      # The `MARK` opcode.
      #
      # @since 0.2.0
      #
      # @see https://github.com/python/cpython/blob/v2.7/Lib/pickle.py#L102
      MARK = 40

      # The `STOP` opcode.
      #
      # @since 0.2.0
      #
      # @see https://github.com/python/cpython/blob/v2.7/Lib/pickle.py#L103
      STOP = 46

      # The `POP` opcode.
      #
      # @since 0.2.0
      #
      # @see https://github.com/python/cpython/blob/v2.7/Lib/pickle.py#L104
      POP = 48

      # The `POP_MARK` opcode.
      #
      # @since 0.2.0
      #
      # @see https://github.com/python/cpython/blob/v2.7/Lib/pickle.py#L105
      POP_MARK = 49

      # The `DUP` opcode.
      #
      # @since 0.2.0
      #
      # @see https://github.com/python/cpython/blob/v2.7/Lib/pickle.py#L106
      DUP = 50

      # The `FLOAT` opcode.
      #
      # @since 0.2.0
      #
      # @see https://github.com/python/cpython/blob/v2.7/Lib/pickle.py#L107
      FLOAT = 70

      # The `INT` opcode.
      #
      # @since 0.2.0
      #
      # @see https://github.com/python/cpython/blob/v2.7/Lib/pickle.py#L108
      INT = 73

      # The `LONG` opcode.
      #
      # @since 0.2.0
      #
      # @see https://github.com/python/cpython/blob/v2.7/Lib/pickle.py#L111
      LONG = 76

      # The `NONE` opcode.
      #
      # @since 0.2.0
      #
      # @see https://github.com/python/cpython/blob/v2.7/Lib/pickle.py#L113
      NONE = 78

      # The `REDUCE` opcode.
      #
      # @since 0.2.0
      #
      # @see https://github.com/python/cpython/blob/v2.7/Lib/pickle.py#L116
      REDUCE = 82

      # The `STRING` opcode.
      #
      # @since 0.2.0
      #
      # @see https://github.com/python/cpython/blob/v2.7/Lib/pickle.py#L117
      STRING = 83

      # The `UNICODE` opcode.
      #
      # @since 0.2.0
      #
      # @see https://github.com/python/cpython/blob/v2.7/Lib/pickle.py#L120
      UNICODE = 86

      # The `APPEND` opcode.
      #
      # @since 0.2.0
      #
      # @see https://github.com/python/cpython/blob/v2.7/Lib/pickle.py#L122
      APPEND = 97

      # The `BUILD` opcode.
      #
      # @since 0.2.0
      #
      # @see https://github.com/python/cpython/blob/v2.7/Lib/pickle.py#L123
      BUILD = 98

      # The `GLOBAL` opcode.
      #
      # @since 0.2.0
      #
      # @see https://github.com/python/cpython/blob/v2.7/Lib/pickle.py#L124
      GLOBAL = 99

      # The `DICT` opcode.
      #
      # @since 0.2.0
      #
      # @see https://github.com/python/cpython/blob/v2.7/Lib/pickle.py#L125
      DICT = 100

      # The `GET` opcode.
      #
      # @since 0.2.0
      #
      # @see https://github.com/python/cpython/blob/v2.7/Lib/pickle.py#L128
      GET = 103

      # The `LIST` opcode.
      #
      # @since 0.2.0
      #
      # @see https://github.com/python/cpython/blob/v2.7/Lib/pickle.py#L132
      LIST = 108

      # The `PUT` opcode.
      #
      # @since 0.2.0
      #
      # @see https://github.com/python/cpython/blob/v2.7/Lib/pickle.py#L135
      PUT = 112

      # The `SETITEM` opcode.
      #
      # @since 0.2.0
      #
      # @see https://github.com/python/cpython/blob/v2.7/Lib/pickle.py#L138
      SETITEM = 115

      # The `TUPLE` opcode.
      #
      # @since 0.2.0
      #
      # @see https://github.com/python/cpython/blob/v2.7/Lib/pickle.py#L139
      TUPLE = 116

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
      #   The decoded raw character.
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
      # Reads a newline terminated string from the pickle string.
      #
      # @return [String]
      #   The read string.
      #
      # @raise [InvalidFormat]
      #   Encountered a premature end of the stream.
      #
      def read_nl_string
        new_string = String.new

        until @io.eof?
          case (char = @io.getc)
          when "\n"
            return new_string
          else
            new_string << char
          end
        end

        raise(InvalidFormat,"unexpected end of stream after the end of a newline terminated string")
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
      #   The decoded UTF-8 character.
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
      #   The decoded UTF-8 character.
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
      # Reads a floating-point decimal from the pickle stream.
      #
      # @return [Float]
      #   The decoded float.
      #
      # @raise [InvalidFormat]
      #   Encountered a non-numeric character or a premature end of the stream.
      #
      def read_float
        new_string = String.new

        until @io.eof?
          case (char = @io.getc)
          when /[0-9\.]/
            new_string << char
          when "\n" # end-of-float
            return new_string.to_f
          else
            raise(InvalidFormat,"encountered a non-numeric character while reading a float: #{char.inspect}")
          end
        end

        raise(InvalidFormat,"unexpected end of stream while parsing a float: #{new_string.inspect}")
      end

      #
      # Reads an integer from the pickle stream.
      #
      # @return [Integer, true, false]
      #   The decoded Integer.
      #   If the integer is `00`, then `false` will be returned.
      #   If the integer is `01`, then `true` will be returned.
      #
      # @raise [InvalidFormat]
      #   Encountered a non-numeric character or a premature end of the stream.
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

      #
      # Reads a `FLOAT` instruction.
      #
      # @return [Instructions::Float]
      #
      # @since 0.2.0
      #
      def read_float_instruction
        Instructions::Float.new(read_float)
      end

      #
      # Reads a `INT` instruction.
      #
      # @return [Instructions::Int]
      #
      # @since 0.2.0
      #
      def read_int_instruction
        Instructions::Int.new(read_int)
      end

      #
      # Reads a `LONG` instruction.
      #
      # @return [Instructions::Long]
      #
      # @since 0.2.0
      #
      def read_long_instruction
        Instructions::Long.new(read_long)
      end

      #
      # Reads a `STRING` instruction.
      #
      # @return [Instructions::String]
      #
      # @since 0.2.0
      #
      def read_string_instruction
        Instructions::String.new(read_string)
      end

      #
      # Reads a `UNICODE` instruction.
      #
      # @return [Instructions::Unicode]
      #
      # @since 0.2.0
      #
      def read_unicode_instruction
        Instructions::String.new(read_unicode_string)
      end

      #
      # Reads a `GLOBAL` instruction.
      #
      # @return [Instructions::Global]
      #
      # @since 0.2.0
      #
      def read_global_instruction
        Instructions::Global.new(read_nl_string,read_nl_string)
      end

      #
      # Reads a `GET` instruction.
      #
      # @return [Instructions::Get]
      #
      # @since 0.2.0
      #
      def read_get_instruction
        Instructions::Get.new(read_int)
      end

      #
      # Reads a `PUT` instruction.
      #
      # @return [Instructions::Put]
      #
      # @since 0.2.0
      #
      def read_put_instruction
        Instructions::Put.new(read_int)
      end

    end
  end
end
