require 'python/pickle/instruction'

module Python
  module Pickle
    module Instructions
      #
      # Represents a pickle `STACK_GLOBAL` instruction.
      #
      # @note introduced in protocol 4.
      #
      class StackGlobal < Instruction

        #
        # Initializes the `STACK_GLOBAL` instruction.
        #
        def initialize
          super(:STACK_GLOBAL)
        end

      end

      # The `STACK_GLOBAL` instruction.
      STACK_GLOBAL = StackGlobal.new
    end
  end
end
