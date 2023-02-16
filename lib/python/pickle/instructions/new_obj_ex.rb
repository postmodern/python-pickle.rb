require 'python/pickle/instruction'

module Python
  module Pickle
    module Instructions
      #
      # Represents a pickle `NEWOBJ_EX` instruction.
      #
      # @note introduced in protocol 3.
      #
      class NewObjEx < Instruction

        #
        # Initializes the `NEWOBJ_EX` instruction.
        #
        def initialize
          super(:NEWOBJ_EX)
        end

      end

      # The `NEWOBJ_EX` instruction.
      NEWOBJ_EX = NewObjEx.new
    end
  end
end
