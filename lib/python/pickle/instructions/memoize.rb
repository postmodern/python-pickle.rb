require 'python/pickle/instruction'

module Python
  module Pickle
    module Instructions
      #
      # Represents a pickle `MEMOIZE` instruction.
      #
      # @note introduced in protocol 4.
      #
      class Memoize < Instruction

        #
        # Initializes the `MEMOIZE` instruction.
        #
        def initialize
          super(:MEMOIZE)
        end

      end

      # The `MEMOIZE` instruction.
      MEMOIZE = Memoize.new
    end
  end
end
