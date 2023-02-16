require 'python/pickle/instruction'
require 'python/pickle/instructions/has_length_and_value'

module Python
  module Pickle
    module Instructions
      #
      # Represents the `BINBYTES8` instruction.
      #
      # @note introduces in protocol 4.
      #
      class BinBytes8 < Instruction

        include HasLengthAndValue

        #
        # Initializes the `BINBYTES8` instruction.
        #
        # @param [Integer] length
        #   The lenght of the `BINBYTES8` value.
        #
        # @param [String] value
        #   The `BINBYTES8` instruction's value.
        #
        def initialize(length,value)
          super(:BINBYTES8,length,value)
        end

      end
    end
  end
end
