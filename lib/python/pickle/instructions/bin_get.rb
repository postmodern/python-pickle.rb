require 'python/pickle/instruction'
require 'python/pickle/instructions/has_value'

module Python
  module Pickle
    module Instructions
      #
      # Represents the `BINGET` instruction.
      #
      class BinGet < Instruction

        include HasValue

        #
        # Initializes the `BINGET` instruction.
        #
        # @param [Integer] value
        #   The `BINGET` instruction's value.
        #
        def initialize(value)
          super(:BINGET,value)
        end

      end
    end
  end
end
