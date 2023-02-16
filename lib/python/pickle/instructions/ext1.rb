require 'python/pickle/instruction'
require 'python/pickle/instructions/has_value'

module Python
  module Pickle
    module Instructions
      #
      # Represents a pickle `EXT1` instruction.
      #
      # @note introduced in protocol 2.
      #
      class Ext1 < Instruction

        include HasValue

        #
        # Initializes the `EXT1` instruction.
        #
        # @param [Integer] value
        #   The extension code.
        #
        def initialize(value)
          super(:EXT1,value)
        end

      end
    end
  end
end
