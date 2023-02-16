require 'python/pickle/instruction'
require 'python/pickle/instructions/has_value'

module Python
  module Pickle
    module Instructions
      #
      # Represents a pickle `FRAME` instruction.
      #
      # @note introduced in protocol 4.
      #
      class Frame < Instruction

        include HasValue

        #
        # Initializes the `FRAME` instruction.
        #
        # @param [Integer] value
        #   The frame's length in bytes.
        #
        def initialize(value)
          super(:FRAME,value)
        end

      end
    end
  end
end
