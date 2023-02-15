require 'python/pickle/instruction'

module Python
  module Pickle
    module Instructions
      #
      # Represents a pickle `NONE` instruction.
      #
      class None < Instruction

        #
        # Initializes the `NONE` instruction.
        #
        def initialize
          super(:NONE)
        end

      end

      # The `NONE` instruction.
      NONE = None.new
    end
  end
end
