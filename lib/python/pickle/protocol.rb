module Python
  module Pickle
    #
    # Common base class for all protocol implementations.
    #
    class Protocol

      # The Pickle stream to read or write to.
      #
      # @return [IO]
      attr_reader :io

      #
      # Initializes the protocol.
      #
      # @param [IO] io
      #   The Pickle stream to read or write to.
      #
      def initialize(io)
        @io = io
      end

      #
      # Reads all instructions from the Pickle stream.
      #
      # @yield [instruction]
      #   If a block is given, it will be passed each parsed Pickle instruction.
      #
      # @yieldparam [Instruction] instruction
      #   A parsed Pickle instruction from the Pickle stream.
      #
      # @return [Array<Instruction>]
      #   All parsed Pickle instructions from the Pickle stream.
      #
      def read
        return enum_for(__method__).to_a unless block_given?

        until @io.eof?
          yield read_instruction
        end
      end

      #
      # Reads an instruction from the pickle stream.
      #
      # @return [Instruction]
      #
      # @abstract
      #
      def read_instruction
        raise(NotImplementedError,"#{self.class}##{__method__} was not implemented")
      end

    end
  end
end
