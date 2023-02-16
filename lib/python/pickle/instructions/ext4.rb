require 'python/pickle/instruction'
require 'python/pickle/instructions/has_value'

module Python
  module Pickle
    module Instructions
      #
      # Represents a pickle `EXT4` instruction.
      #
      # @note introduced in protocol 2.
      #
      class Ext4 < Instruction

        include HasValue

        #
        # Initializes the `EXT4` instruction.
        #
        # @param [Integer] value
        #   The extension code.
        #
        def initialize(value)
          super(:EXT4,value)
        end

      end
    end
  end
end
