require 'python/pickle/instruction'
require 'python/pickle/instructions/has_length_and_value'

module Python
  module Pickle
    module Instructions
      #
      # Represents the `BINBYTES` instruction.
      #
      # @note introduces in protocol 3.
      #
      class BinBytes < Instruction

        include HasLengthAndValue

        #
        # Initializes the `BINBYTES` instruction.
        #
        # @param [Integer] length
        #   The length of the `BINBYTES` value.
        #
        # @param [String] value
        #   The `BINBYTES` instruction's value.
        #
        def initialize(length,value)
          super(:BINBYTES,length,value)
        end

      end
    end
  end
end
