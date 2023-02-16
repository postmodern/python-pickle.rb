require 'python/pickle/instruction'

module Python
  module Pickle
    module Instructions
      #
      # Represents the `EMPTY_DICT` instruction.
      #
      # @note introduced in protocol 1.
      #
      class EmptyDict < Instruction

        #
        # Initializes the `EMPTY_DICT` instruction.
        #
        def initialize
          super(:EMPTY_DICT)
        end

      end

      # The `EMPTY_DICT` instruction.
      EMPTY_DICT = EmptyDict.new
    end
  end
end
