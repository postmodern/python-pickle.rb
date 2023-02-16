require 'python/pickle/instruction'

module Python
  module Pickle
    module Instructions
      #
      # Represents a pickle `POP_MARK` instruction.
      #
      class PopMark < Instruction

        #
        # Initializes the `POP_MARK` instruction.
        #
        def initialize
          super(:POP_MARK)
        end

      end

      # The `POP_MARK` instruction.
      POP_MARK = PopMark.new
    end
  end
end
