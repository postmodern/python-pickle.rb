require 'python/pickle/instruction'
require 'python/pickle/instructions/has_length_and_value'

module Python
  module Pickle
    module Instructions
      #
      # Represents the `BINSTRING` instruction.
      #
      # @note introduces in protocol 1.
      #
      class BinString < Instruction

        include HasLengthAndValue

        #
        # Initializes the `BINSTRING` instruction.
        #
        # @param [Integer] length
        #   The lenght of the `BINSTRING` value.
        #
        # @param [String] value
        #   The `BINSTRING` instruction's value.
        #
        def initialize(length,value)
          super(:BINSTRING,length,value)
        end

      end
    end
  end
end
