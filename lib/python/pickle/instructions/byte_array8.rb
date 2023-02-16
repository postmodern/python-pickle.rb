require 'python/pickle/instruction'
require 'python/pickle/instructions/has_length_and_value'

module Python
  module Pickle
    module Instructions
      #
      # Represents the `BYTEARRAY8` instruction.
      #
      # @note introduces in protocol 5.
      #
      class ByteArray8 < Instruction

        include HasLengthAndValue

        #
        # Initializes the `BYTEARRAY8` instruction.
        #
        # @param [Integer] length
        #   The lenght of the `BYTEARRAY8` value.
        #
        # @param [String] value
        #   The `BYTEARRAY8` instruction's value.
        #
        def initialize(length,value)
          super(:BYTEARRAY8,length,value)
        end

      end
    end
  end
end
