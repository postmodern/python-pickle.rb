module Python
  module Pickle
    module Instructions
      #
      # A mixin which adds a value to an instruction class.
      #
      module HasValue
        # The value associated with the instruction.
        #
        # @return [Object]
        attr_reader :value

        #
        # Initializes the instruction.
        #
        # @param [Symbol] opcode
        #
        # @param [Object] value
        #
        def initialize(opcode,value)
          super(opcode)

          @value = value
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
          super(other) && other.kind_of?(HasValue) && (@value == other.value)
        end

        #
        # Converts the instruction to a String.
        #
        # @return [String]
        #
        def to_s
          "#{super} #{@value.inspect}"
        end
      end
    end
  end
end
