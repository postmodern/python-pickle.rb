require 'python/pickle/instruction'

module Python
  module Pickle
    module Instructions
      #
      # Represents a pickle `DUP` instruction.
      #
      class Dup < Instruction

        #
        # Initializes the `DUP` instruction.
        #
        def initialize
          super(:DUP)
        end

      end

      # The `DUP` instruction.
      DUP = Dup.new
    end
  end
end
