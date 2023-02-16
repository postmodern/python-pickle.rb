require 'python/pickle/instruction'
require 'python/pickle/instructions/has_value'

module Python
  module Pickle
    module Instructions
      #
      # Represents the `BININT1` instruction.
      #
      # @note introduces in protocol 1.
      #
      class BinInt1 < Instruction

        include HasValue

        #
        # Initializes the `BININT1` instruction.
        #
        # @param [BinInt1] value
        #   The `BININT1` instruction's value.
        #
        def initialize(value)
          super(:BININT1,value)
        end

      end
    end
  end
end
