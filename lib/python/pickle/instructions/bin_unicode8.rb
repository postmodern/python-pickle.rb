require 'python/pickle/instruction'
require 'python/pickle/instructions/has_length_and_value'

module Python
  module Pickle
    module Instructions
      #
      # Represents the `BINUNICODE8` instruction.
      #
      # @note introduces in protocol 4.
      #
      class BinUnicode8 < Instruction

        include HasLengthAndValue

        #
        # Initializes the `BINUNICODE8` instruction.
        #
        # @param [Integer] length
        #   The lenght of the `BINUNICODE8` value.
        #
        # @param [String] value
        #   The `BINUNICODE8` instruction's value.
        #
        def initialize(length,value)
          super(:BINUNICODE8,length,value)
        end

      end
    end
  end
end
