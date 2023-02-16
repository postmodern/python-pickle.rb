require 'python/pickle/instruction'
require 'python/pickle/instructions/has_value'

module Python
  module Pickle
    module Instructions
      #
      # Represents the `LONG_BINGET` instruction.
      #
      class LongBinGet < Instruction

        include HasValue

        #
        # Initializes the `LONG_BINGET` instruction.
        #
        # @param [Integer] value
        #   The `LONG_BINGET` instruction's value.
        #
        def initialize(value)
          super(:LONG_BINGET,value)
        end

      end
    end
  end
end
