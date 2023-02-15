require 'python/pickle/instruction'
require 'python/pickle/instructions/has_value'

module Python
  module Pickle
    module Instructions
      class String < Instruction

        include HasValue

        #
        # Initializes the `STRING` instruction.
        #
        # @param [String] value
        #   The `STRING` instruction's value.
        #
        def initialize(value)
          super(:STRING,value)
        end

      end
    end
  end
end
