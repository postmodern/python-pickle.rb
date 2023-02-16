require 'python/pickle/instruction'
require 'python/pickle/instructions/has_value'

module Python
  module Pickle
    module Instructions
      #
      # Represents the `BINPUT` instruction.
      #
      # @note introduced in protocol 1.
      #
      class BinPut < Instruction

        include HasValue

        #
        # Initializes the `BINPUT` instruction.
        #
        # @param [Integer] value
        #   The `BINPUT` instruction's value.
        #
        def initialize(value)
          super(:BINPUT,value)
        end

      end
    end
  end
end
