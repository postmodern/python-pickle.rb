require 'python/pickle/instruction'

module Python
  module Pickle
    module Instructions
      #
      # Represents a pickle `NEXT_BUFFER` instruction.
      #
      # @note introduced in protocol 4.
      #
      # @since 0.2.0
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
      #
      # @since 0.2.0
      NEXT_BUFFER = NextBuffer.new
    end
  end
end
