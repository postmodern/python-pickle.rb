module Python
  module Pickle
    class Instruction

      # The opcode name.
      #
      # @return [Symbol]
      attr_reader :opcode

      #
      # Initializes the instruction.
      #
      # @param [Symbol] opcode
      #
      def initialize(opcode)
        @opcode = opcode
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
        (self.class == other.class) && (@opcode == other.opcode)
      end

      #
      # Converts the instruction into a String.
      #
      # @return [String]
      #
      def to_s
        @opcode.to_s
      end

      #
      # Inspects the instruction.
      #
      # @return [String]
      #
      def inspect
        "#<#{self.class}: #{self}>"
      end

    end
  end
end
