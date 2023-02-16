require 'python/pickle/instruction'

module Python
  module Pickle
    module Instructions
      #
      # Represents a pickle `APPENDS` instruction.
      #
      # @note Introduced in protocol 1.
      #
      class Appends < Instruction

        #
        # Initializes the `APPENDS` instruction.
        #
        def initialize
          super(:APPENDS)
        end

      end

      # The `APPENDS` instruction.
      APPENDS = Appends.new
    end
  end
end
