require 'python/pickle/instruction'

module Python
  module Pickle
    module Instructions
      #
      # Represents a pickle `NEWTRUE` instruction.
      #
      class NewTrue < Instruction

        #
        # Initializes the `NEWTRUE` instruction.
        #
        def initialize
          super(:NEWTRUE)
        end

      end

      # The `NEWTRUE` instruction.
      NEWTRUE = NewTrue.new
    end
  end
end
