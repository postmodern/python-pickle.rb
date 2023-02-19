module Python
  module Pickle
    module Instructions
      module HasNamespaceAndName
        # The constant's namespace.
        #
        # @return [String]
        attr_reader :namespace

        # The constant name.
        #
        # @return [String]
        attr_reader :name

        #
        # Initializes the instruction.
        #
        # @param [Symbol] opcode
        #   The instruction's opcode.
        #
        # @param [String] namespace
        #   The namespace name for the constant.
        #
        # @param [String] name
        #   The name of the constant.
        #
        def initialize(opcode,namespace,name)
          super(opcode)

          @namespace = namespace
          @name      = name
        end

        #
        # Compares the instruction to another instruction.
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
        # Converts the instructions to a String.
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
