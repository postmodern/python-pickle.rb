module Python
  module Pickle
    #
    # Represents a Python `bytearray` object.
    #
    class ByteArray < String

      # Mapping of python `codecs` encoding names and their Ruby equivalents.
      #
      # @api private
      ENCODINGS = {
        nil       => Encoding::ASCII_8BIT,
        'latin-1' => Encoding::ISO_8859_1
      }

      #
      # Initializes the byte array.
      #
      # @param [String] string
      #   The contents of the byte array.
      #
      # @param [String, nil] encoding
      #   The optional encoding name.
      #
      def initialize(string='', encoding=nil)
        super(string, encoding: ENCODINGS.fetch(encoding))
      end

      #
      # Inspects the byte array object.
      #
      # @return [String]
      #
      def inspect
        "#<#{self.class}: #{super}>"
      end

    end
  end
end
