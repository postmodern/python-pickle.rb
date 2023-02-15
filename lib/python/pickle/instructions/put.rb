require 'python/pickle/instruction'
require 'python/pickle/instructions/has_value'

module Python
  module Pickle
    module Instructions
      class Put < Instruction

        include HasValue

        #
        # Initializes the `PUT` instruction.
        #
        # @param [Integer] value
        #   The `PUT` instruction's value.
        #
        def initialize(value)
          super(:PUT,value)
        end

      end
    end
  end
end
