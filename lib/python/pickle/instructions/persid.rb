require 'python/pickle/instruction'
require 'python/pickle/instructions/has_value'

module Python
  module Pickle
    module Instructions
      #
      # Represents the `PERSID` instruction.
      #
      # @note introduced in protocol 0.
      #
      # @since 0.2.0
      #
      class PersID < Instruction

        include HasValue

        #
        # Initializes the `PERSID` instruction.
        #
        # @param [String] value
        #   The `PERSID` instruction's value.
        #
        def initialize(value)
          super(:PERSID,value)
        end

      end
    end
  end
end
