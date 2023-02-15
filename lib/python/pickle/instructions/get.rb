require 'python/pickle/instruction'
require 'python/pickle/instructions/has_value'

module Python
  module Pickle
    module Instructions
      class Get < Instruction

        include HasValue

        #
        # Initializes the `GET` instruction.
        #
        # @param [Integer] value
        #   The `GET` instruction's value.
        #
        def initialize(value)
          super(:GET,value)
        end

      end
    end
  end
end
