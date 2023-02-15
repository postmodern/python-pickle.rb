require 'python/pickle/instruction'

module Python
  module Pickle
    module Instructions
      #
      # Represents a pickle `STOP` instruction.
      #
      class Stop < Instruction

        #
        # Initializes the `STOP` instruction.
        #
        def initialize
          super(:STOP)
        end

      end

      # The `STOP` instruction.
      STOP = Stop.new
    end
  end
end
