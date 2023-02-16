require 'python/pickle/instruction'

module Python
  module Pickle
    module Instructions
      #
      # Represents a pickle `SETITEMS` instruction.
      #
      # @note Introduced in protocol 1.
      #
      class SetItems < Instruction

        #
        # Initializes the `SETITEMS` instruction.
        #
        def initialize
          super(:SETITEMS)
        end

      end

      # The `SETITEMS` instruction.
      SETITEMS = SetItems.new
    end
  end
end
