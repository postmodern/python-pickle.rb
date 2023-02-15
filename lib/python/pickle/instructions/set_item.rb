require 'python/pickle/instruction'

module Python
  module Pickle
    module Instructions
      #
      # Represents a pickle `SETITEM` instruction.
      #
      class SetItem < Instruction

        #
        # Initializes the `SETITEM` instruction.
        #
        def initialize
          super(:SETITEM)
        end

      end

      # The `SETITEM` instruction.
      SETITEM = SetItem.new
    end
  end
end
