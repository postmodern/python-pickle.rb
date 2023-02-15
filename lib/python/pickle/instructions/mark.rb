require 'python/pickle/instruction'

module Python
  module Pickle
    module Instructions
      #
      # Represents a pickle `MARK` instruction.
      #
      class Mark < Instruction

        #
        # Initializes the `MARK` instruction.
        #
        def initialize
          super(:MARK)
        end

      end

      # The `MARK` instruction.
      MARK = Mark.new
    end
  end
end
