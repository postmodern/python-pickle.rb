require 'python/pickle/instruction'
require 'python/pickle/instructions/has_value'

module Python
  module Pickle
    module Instructions
      #
      # Represents the `BINFLOAT` instruction.
      #
      # @note introduces in protocol 1.
      #
      class BinFloat < Instruction

        include HasValue

        #
        # Initializes the `BINFLOAT` instruction.
        #
        # @param [BinFloat] value
        #   The `BINFLOAT` instruction's value.
        #
        def initialize(value)
          super(:BINFLOAT,value)
        end

      end
    end
  end
end
