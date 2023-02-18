require 'python/pickle/instruction'
require 'python/pickle/instructions/has_length_and_value'

module Python
  module Pickle
    module Instructions
      #
      # Represents the `BINUNICODE` instruction.
      #
      # @note introduces in protocol 1.
      #
      class BinUnicode < Instruction

        include HasLengthAndValue

        #
        # Initializes the `BINUNICODE` instruction.
        #
        # @param [Integer] length
        #   The length of the `BINUNICODE` value.
        #
        # @param [String] value
        #   The `BINUNICODE` instruction's value.
        #
        def initialize(length,value)
          super(:BINUNICODE,length,value)
        end

      end
    end
  end
end
