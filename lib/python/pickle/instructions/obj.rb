require 'python/pickle/instruction'

module Python
  module Pickle
    module Instructions
      #
      # Represents a pickle `OBJ` instruction.
      #
      # @note introduced in protocol 0.
      #
      # @since 0.2.0
      #
      class Obj < Instruction

        #
        # Initializes the `OBJ` instruction.
        #
        def initialize
          super(:OBJ)
        end

      end

      # The `OBJ` instruction.
      OBJ = Obj.new
    end
  end
end
