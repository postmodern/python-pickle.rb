require 'python/pickle/instruction'
require 'python/pickle/instructions/has_length_and_value'

module Python
  module Pickle
    module Instructions
      #
      # Represents the `LONG4` instruction.
      #
      # @note introduces in protocol 1.
      #
      class Long4 < Instruction

        include HasLengthAndValue

        #
        # Initializes the `LONG4` instruction.
        #
        # @param [Integer] length
        #   The length of the `LONG4` value in bytes.
        #
        # @param [Long4] value
        #   The `LONG4` instruction's value.
        #
        def initialize(length,value)
          super(:LONG4,length,value)
        end

      end
    end
  end
end
