require 'python/pickle/instruction'

module Python
  module Pickle
    module Instructions
      #
      # Represents a pickle `EMPTY_TUPLE` instruction.
      #
      # @note Introduced in protocol 1.
      #
      class EmptyTuple < Instruction

        #
        # Initializes the `EMPTY_TUPLE` instruction.
        #
        def initialize
          super(:EMPTY_TUPLE)
        end

      end

      # The `EMPTY_TUPLE` instruction.
      EMPTY_TUPLE = EmptyTuple.new
    end
  end
end
