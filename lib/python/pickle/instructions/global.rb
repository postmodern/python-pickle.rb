require 'python/pickle/instruction'
require 'python/pickle/instructions/has_namespace_and_name'

module Python
  module Pickle
    module Instructions
      #
      # Represents the `GLOBAL` instruction.
      #
      # @note introduced in protocol 0.
      #
      class Global < Instruction

        include HasNamespaceAndName

        #
        # Initializes a `GLOBAL` instruction.
        #
        # @param [String] namespace
        #   The namespace name for the constant.
        #
        # @param [String] name
        #   The name of the constant.
        #
        def initialize(namespace,name)
          super(:GLOBAL,namespace,name)
        end

      end
    end
  end
end
