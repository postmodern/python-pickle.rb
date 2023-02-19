require 'python/pickle/instruction'
require 'python/pickle/instructions/has_value'

module Python
  module Pickle
    module Instructions
      #
      # Represents the `BINPERSID` instruction.
      #
      # @note introduced in protocol 0.
      #
      # @since 0.2.0
      #
      class BinPersID < Instruction

        #
        # Initializes the `BINPERSID` instruction.
        #
        def initialize
          super(:BINPERSID)
        end

      end

      # Represents the `BINPERSID` instruction.
      #
      # @since 0.2.0
      BINPERSID = BinPersID.new
    end
  end
end
