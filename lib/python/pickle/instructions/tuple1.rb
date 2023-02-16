require 'python/pickle/instruction'

module Python
  module Pickle
    module Instructions
      #
      # Represents a pickle `TUPLE1` instruction.
      #
      class Tuple1 < Instruction

        #
        # Initializes the `TUPLE1` instruction.
        #
        def initialize
          super(:TUPLE1)
        end

      end

      # The `TUPLE1` instruction.
      TUPLE1 = Tuple1.new
    end
  end
end
