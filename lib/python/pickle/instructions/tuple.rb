require 'python/pickle/instruction'

module Python
  module Pickle
    module Instructions
      #
      # Represents a pickle `TUPLE` instruction.
      #
      class Tuple < Instruction

        #
        # Initializes the `TUPLE` instruction.
        #
        def initialize
          super(:TUPLE)
        end

      end

      # The `TUPLE` instruction.
      TUPLE = Tuple.new
    end
  end
end
