require 'python/pickle/instruction'

module Python
  module Pickle
    module Instructions
      #
      # Represents a pickle `FROZENSET` instruction.
      #
      # @note introduced in protocol 4.
      #
      class FrozenSet < Instruction

        #
        # Initializes the `FROZENSET` instruction.
        #
        def initialize
          super(:FROZENSET)
        end

      end

      # The `FROZENSET` instruction.
      FROZENSET = FrozenSet.new
    end
  end
end
