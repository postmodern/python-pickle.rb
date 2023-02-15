require 'python/pickle/instruction'

module Python
  module Pickle
    module Instructions
      #
      # Represents a pickle `LIST` instruction.
      #
      class List < Instruction

        #
        # Initializes the `LIST` instruction.
        #
        def initialize
          super(:LIST)
        end

      end

      # The `LIST` instruction.
      LIST = List.new
    end
  end
end
