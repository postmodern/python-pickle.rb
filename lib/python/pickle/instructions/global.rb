require 'python/pickle/instruction'
require 'python/pickle/instructions/has_value'

module Python
  module Pickle
    module Instructions
      class Global < Instruction

        # The global object namespace.
        #
        # @return [String]
        attr_reader :namespace

        # The global object name.
        #
        # @return [String]
        attr_reader :name

        #
        # Initializes the `GLOBAL` instruction.
        #
        # @param [String] namespace
        #   The namespace name for the global object.
        #
        # @param [String] name
        #   The name of the global object.
        #
        def initialize(namespace,name)
          super(:GLOBAL)

          @namespace = namespace
          @name      = name
        end

        #
        # Compares the `GLOBAL` instruction to another instruction.
        #
        # @param [Instruction] other
        #   The other instruction to compare against.
        #
        # @return [Boolean]
        #   Indicates whether the other instruction matches this one.
        #
        def ==(other)
          super(other) && \
            (@namespace == other.namespace) && \
            (@name == other.name)
        end

        #
        # Converts the `GLOBAL` instructions to a String.
        #
        # @return [String]
        #
        def to_s
          "#{super} #{@namespace}.#{@name}"
        end

      end
    end
  end
end
