require 'python/pickle/instruction'

module Python
  module Pickle
    module Instructions
      #
      # Represents a pickle `EMPTY_LIST` instruction.
      #
      # @note introduced in protocol 1.
      #
      class EmptyList < Instruction

        #
        # Initializes the `EMPTY_LIST` instruction.
        #
        def initialize
          super(:EMPTY_LIST)
        end

      end

      # The `EMPTY_LIST` instruction.
      EMPTY_LIST = EmptyList.new
    end
  end
end
