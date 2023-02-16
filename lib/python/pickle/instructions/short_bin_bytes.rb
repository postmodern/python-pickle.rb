require 'python/pickle/instruction'
require 'python/pickle/instructions/has_length_and_value'

module Python
  module Pickle
    module Instructions
      #
      # Represents the `SHORT_BINBYTES` instruction.
      #
      # @note introduces in protocol 3.
      #
      class ShortBinBytes < Instruction

        include HasLengthAndValue

        #
        # Initializes the `SHORT_BINBYTES` instruction.
        #
        # @param [Integer] length
        #   The lenght of the `SHORT_BINBYTES` value.
        #
        # @param [String] value
        #   The `SHORT_BINBYTES` instruction's value.
        #
        def initialize(length,value)
          super(:SHORT_BINBYTES,length,value)
        end

      end
    end
  end
end
