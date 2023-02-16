require 'python/pickle/instruction'

module Python
  module Pickle
    module Instructions
      #
      # Represents a pickle `TUPLE2` instruction.
      #
      class Tuple2 < Instruction

        #
        # Initializes the `TUPLE2` instruction.
        #
        def initialize
          super(:TUPLE2)
        end

      end

      # The `TUPLE2` instruction.
      TUPLE2 = Tuple2.new
    end
  end
end
