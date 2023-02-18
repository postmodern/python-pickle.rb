require 'python/pickle/instruction'
require 'python/pickle/instructions/has_length_and_value'

module Python
  module Pickle
    module Instructions
      #
      # Represents the `SHORT_BINUNICODE` instruction.
      #
      # @note introduces in protocol 4.
      #
      class ShortBinUnicode < Instruction

        include HasLengthAndValue

        #
        # Initializes the `SHORT_BINUNICODE` instruction.
        #
        # @param [Integer] length
        #   The length of the `SHORT_BINUNICODE` value.
        #
        # @param [String] value
        #   The `SHORT_BINUNICODE` instruction's value.
        #
        def initialize(length,value)
          super(:SHORT_BINUNICODE,length,value)
        end

      end
    end
  end
end
