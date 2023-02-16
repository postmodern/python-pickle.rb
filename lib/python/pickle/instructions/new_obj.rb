require 'python/pickle/instruction'

module Python
  module Pickle
    module Instructions
      #
      # Represents a pickle `NEWOBJ` instruction.
      #
      # @note introduced in protocol 2.
      #
      class NewObj < Instruction

        #
        # Initializes the `NEWOBJ` instruction.
        #
        def initialize
          super(:NEWOBJ)
        end

      end

      # The `NEWOBJ` instruction.
      NEWOBJ = NewObj.new
    end
  end
end
