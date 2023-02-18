require 'python/pickle/instruction'
require 'python/pickle/instructions/has_length_and_value'

module Python
  module Pickle
    module Instructions
      #
      # Represents the `SHORT_BINSTRING` instruction.
      #
      # @note introduces in protocol 1.
      #
      class ShortBinString < Instruction

        include HasLengthAndValue

        #
        # Initializes the `SHORT_BINSTRING` instruction.
        #
        # @param [Integer] length
        #   The length of the `SHORT_BINSTRING` value.
        #
        # @param [String] value
        #   The `SHORT_BINSTRING` instruction's value.
        #
        def initialize(length,value)
          super(:SHORT_BINSTRING,length,value)
        end

      end
    end
  end
end
