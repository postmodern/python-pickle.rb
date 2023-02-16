module Python
  module Pickle
    module Instructions
      #
      # A mixin which adds a length and a value to an instruction class.
      #
      module HasLengthAndValue
        # The length of the value associated with the instruction.
        #
        # @return [Integer]
        attr_reader :length

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
        def initialize(opcode,length,value)
          super(opcode)

          @value  = value
          @length = length
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
          super(other) &&
            other.kind_of?(HasLengthAndValue) &&
            (@length == other.length && @value == other.value)
        end

        #
        # Converts the instruction to a String.
        #
        # @return [String]
        #
        def to_s
          "#{super} #{@length.inspect} #{@value.inspect}"
        end
      end
    end
  end
end
