require 'python/pickle/instruction'

module Python
  module Pickle
    module Instructions
      #
      # Represents a pickle `TUPLE3` instruction.
      #
      class Tuple3 < Instruction

        #
        # Initializes the `TUPLE3` instruction.
        #
        def initialize
          super(:TUPLE3)
        end

      end

      # The `TUPLE3` instruction.
      TUPLE3 = Tuple3.new
    end
  end
end
