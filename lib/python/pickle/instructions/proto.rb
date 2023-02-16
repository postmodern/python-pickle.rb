require 'python/pickle/instruction'
require 'python/pickle/instructions/has_value'

module Python
  module Pickle
    module Instructions
      #
      # Represents the `PROTO` instruction.
      #
      # @note introduces in protocol 2.
      #
      class Proto < Instruction

        include HasValue

        #
        # Initializes the `PROTO` instruction.
        #
        # @param [Proto] value
        #   The `PROTO` instruction's value.
        #
        def initialize(value)
          super(:PROTO,value)
        end

      end
    end
  end
end
