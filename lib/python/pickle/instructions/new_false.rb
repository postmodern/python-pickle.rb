require 'python/pickle/instruction'

module Python
  module Pickle
    module Instructions
      #
      # Represents a pickle `NEWFALSE` instruction.
      #
      class NewFalse < Instruction

        #
        # Initializes the `NEWFALSE` instruction.
        #
        def initialize
          super(:NEWFALSE)
        end

      end

      # The `NEWFALSE` instruction.
      NEWFALSE = NewFalse.new
    end
  end
end
