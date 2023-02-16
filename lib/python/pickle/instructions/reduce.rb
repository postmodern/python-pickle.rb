require 'python/pickle/instruction'

module Python
  module Pickle
    module Instructions
      #
      # Represents a pickle `REDUCE` instruction.
      #
      class Reduce < Instruction

        #
        # Initializes the `REDUCE` instruction.
        #
        def initialize
          super(:REDUCE)
        end

      end

      # The `REDUCE` instruction.
      REDUCE = Reduce.new
    end
  end
end
