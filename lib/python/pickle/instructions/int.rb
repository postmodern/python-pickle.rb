require 'python/pickle/instruction'
require 'python/pickle/instructions/has_value'

module Python
  module Pickle
    module Instructions
      class Int < Instruction

        include HasValue

        #
        # Initializes the `INT` instruction.
        #
        # @param [Integer] value
        #   The `INT` instruction's value.
        #
        def initialize(value)
          super(:INT,value)
        end

      end
    end
  end
end
