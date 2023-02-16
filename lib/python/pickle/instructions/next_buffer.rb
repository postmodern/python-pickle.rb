require 'python/pickle/instruction'

module Python
  module Pickle
    module Instructions
      #
      # Represents a pickle `NEXT_BUFFER` instruction.
      #
      # @note introduced in protocol 4.
      #
      class NextBuffer < Instruction

        #
        # Initializes the `NEXT_BUFFER` instruction.
        #
        def initialize
          super(:NEXT_BUFFER)
        end

      end

      # The `NEXT_BUFFER` instruction.
      NEXT_BUFFER = NextBuffer.new
    end
  end
end
