require 'python/pickle/instruction'

module Python
  module Pickle
    module Instructions
      #
      # Represents a pickle `EMPTY_SET` instruction.
      #
      # @note introduced in protocol 4.
      #
      class EmptySet < Instruction

        #
        # Initializes the `EMPTY_SET` instruction.
        #
        def initialize
          super(:EMPTY_SET)
        end

      end

      # The `EMPTY_SET` instruction.
      EMPTY_SET = EmptySet.new
    end
  end
end
