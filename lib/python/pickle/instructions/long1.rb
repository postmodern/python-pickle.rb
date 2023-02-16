require 'python/pickle/instruction'
require 'python/pickle/instructions/has_length_and_value'

module Python
  module Pickle
    module Instructions
      #
      # Represents the `LONG1` instruction.
      #
      # @note introduces in protocol 1.
      #
      class Long1 < Instruction

        include HasLengthAndValue

        #
        # Initializes the `LONG1` instruction.
        #
        # @param [Integer] length
        #   The length of the `LONG1` value in bytes.
        #
        # @param [Long1] value
        #   The `LONG1` instruction's value.
        #
        def initialize(length,value)
          super(:LONG1,length,value)
        end

      end
    end
  end
end
