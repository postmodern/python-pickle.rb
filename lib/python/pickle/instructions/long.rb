require 'python/pickle/instruction'
require 'python/pickle/instructions/has_value'

module Python
  module Pickle
    module Instructions
      class Long < Instruction

        include HasValue

        #
        # Initializes the `LONG` instruction.
        #
        # @param [Integer] value
        #   The `LONG` instruction's value.
        #
        def initialize(value)
          super(:LONG,value)
        end

      end
    end
  end
end
