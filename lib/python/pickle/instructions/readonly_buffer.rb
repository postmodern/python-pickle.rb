require 'python/pickle/instruction'

module Python
  module Pickle
    module Instructions
      #
      # Represents a pickle `READONLY_BUFFER` instruction.
      #
      # @note introduced in protocol 5.
      #
      # @since 0.2.0
      #
      class ReadonlyBuffer < Instruction

        #
        # Initializes the `READONLY_BUFFER` instruction.
        #
        def initialize
          super(:READONLY_BUFFER)
        end

      end

      # The `READONLY_BUFFER` instruction.
      #
      # @since 0.2.0
      READONLY_BUFFER = ReadonlyBuffer.new
    end
  end
end
