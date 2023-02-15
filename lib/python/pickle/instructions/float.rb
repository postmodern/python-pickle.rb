require 'python/pickle/instruction'
require 'python/pickle/instructions/has_value'

module Python
  module Pickle
    module Instructions
      class Float < Instruction

        include HasValue

        #
        # Initializes the `FLOAT` instruction.
        #
        # @param [Float] value
        #   The `FLOAT` instruction's value.
        #
        def initialize(value)
          super(:FLOAT,value)
        end

      end
    end
  end
end
