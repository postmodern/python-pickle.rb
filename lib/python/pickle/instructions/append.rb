require 'python/pickle/instruction'

module Python
  module Pickle
    module Instructions
      #
      # Represents a pickle `APPEND` instruction.
      #
      class Append < Instruction

        #
        # Initializes the `APPEND` instruction.
        #
        def initialize
          super(:APPEND)
        end

      end

      # The `APPEND` instruction.
      APPEND = Append.new
    end
  end
end
