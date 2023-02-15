require 'python/pickle/instruction'

module Python
  module Pickle
    module Instructions
      #
      # Represents a pickle `POP` instruction.
      #
      class Pop < Instruction

        #
        # Initializes the `POP` instruction.
        #
        def initialize
          super(:POP)
        end

      end

      # The `POP` instruction.
      POP = Pop.new
    end
  end
end
