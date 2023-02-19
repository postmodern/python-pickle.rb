require 'python/pickle/instruction'
require 'python/pickle/instructions/has_namespace_and_name'

module Python
  module Pickle
    module Instructions
      #
      # Represents the `INST` instruction.
      #
      # @note introduced in protocol 0.
      #
      # @since 0.2.0
      #
      class Inst < Instruction

        include HasNamespaceAndName

        #
        # Initializes a `INST` instruction.
        #
        # @param [String] namespace
        #   The namespace name for the constant.
        #
        # @param [String] name
        #   The name of the constant.
        #
        def initialize(namespace,name)
          super(:INST,namespace,name)
        end

      end
    end
  end
end
