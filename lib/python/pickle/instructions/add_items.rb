require 'python/pickle/instruction'

module Python
  module Pickle
    module Instructions
      #
      # Represents a pickle `ADDITEMS` instruction.
      #
      # @note Introduced in protocol 4.
      #
      class AddItems < Instruction

        #
        # Initializes the `ADDITEMS` instruction.
        #
        def initialize
          super(:ADDITEMS)
        end

      end

      # The `ADDITEMS` instruction.
      ADDITEMS = AddItems.new
    end
  end
end
