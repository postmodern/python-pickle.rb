require 'python/pickle/instruction'

module Python
  module Pickle
    module Instructions
      #
      # Represents a pickle `BUILD` instruction.
      #
      class Build < Instruction

        #
        # Initializes the `BUILD` instruction.
        #
        def initialize
          super(:BUILD)
        end

      end

      # The `BUILD` instruction.
      BUILD = Build.new
    end
  end
end
