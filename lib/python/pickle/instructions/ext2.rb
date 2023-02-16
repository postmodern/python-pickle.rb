require 'python/pickle/instruction'
require 'python/pickle/instructions/has_value'

module Python
  module Pickle
    module Instructions
      #
      # Represents a pickle `EXT2` instruction.
      #
      # @note introduced in protocol 2.
      #
      class Ext2 < Instruction

        include HasValue

        #
        # Initializes the `EXT2` instruction.
        #
        # @param [Integer] value
        #   The extension code.
        #
        def initialize(value)
          super(:EXT2,value)
        end

      end
    end
  end
end
