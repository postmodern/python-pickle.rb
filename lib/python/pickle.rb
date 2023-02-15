require 'python/pickle/protocol0'
require 'python/pickle/protocol1'
require 'python/pickle/protocol2'
require 'python/pickle/protocol3'
require 'python/pickle/protocol4'
require 'python/pickle/protocol5'
require 'python/pickle/exceptions'
require 'stringio'

module Python
  #
  # A modern Ruby implementation of the Python Pickle serialization format.
  #
  module Pickle
    # Mapping of protocol versions to protocol parsers.
    #
    # @api private
    PROTOCOL_VERSIONS = {
      0 => Protocol0,
      1 => Protocol1,
      2 => Protocol2,
      3 => Protocol3,
      4 => Protocol4,
      5 => Protocol5
    }

    # The default protocol version to use.
    #
    # @api public
    DEFAULT_PROTCOL = 4

    # The highest protocol version supported.
    #
    # @api public
    HIGHEST_PROTOCOL = 5

    #
    # Parses a Python pickle stream.
    #
    # @param [String, IO] data
    #   The Python pickle stream to parse.
    #
    # @param [Integer, nil] protocol
    #   The explicit protocol version to use. If `nil` the protcol version will
    #   be inferred by inspecting the first two bytes of the stream.
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
    # @api public
    #
    def self.parse(data, protocol: nil, &block)
      io = case data 
           when String then StringIO.new(data)
           when IO     then data
           else
             raise(ArgumentError,"argument must be either an IO object or a String: #{io.inspect}")
           end

      if protocol
        if (protocol < 0) || (protocol > HIGHEST_PROTOCOL)
          raise(ArgumentError,"protocol must be between 0 or #{HIGHEST_PROTOCOL}, but was #{protocol.inspect}")
        end
      else
        protocol = infer_protocol_version(io)
      end

      protocol_class = PROTOCOL_VERSIONS.fetch(protocol)
      protocol       = protocol_class.new(io)

      return protocol.read(&block)
    end

    #
    # Deserializes the Python Pickle stream into a Ruby object.
    #
    # @param [String, IO] data
    #   The Python pickle stream to parse.
    #
    # @param [Integer, nil] protocol
    #   The explicit protocol version to use. If `nil` the protcol version will
    #   be inferred by inspecting the first two bytes of the stream.
    #
    # @api public
    #
    def self.load(data, protocol: nil)
    end

    #
    # Serializes the Ruby object into Python Pickle data.
    #
    # @param [Object] object
    #   The Ruby object to serialize.
    #
    # @param [IO] output
    #   The option output to write the Pickle data to.
    #
    # @param [Integer] protocol
    #   The desired Python Pickle protocol to use.
    #
    # @api public
    #
    def self.dump(object,output=nil, protocol: DEFAULT_PROTOCOL)
      if (protocol < 0) || (protocol > HIGHEST_PROTOCOL)
        raise(ArgumentError,"protocol must be between 0 or #{HIGHEST_PROTOCOL}, but was #{protocol.inspect}")
      end
    end

    #
    # Infers the protocol version from the IO stream.
    #
    # @param [IO] io
    #   The IO stream to inspect.
    #
    # @return [Integer]
    #   The infered Python Pickle protocol version.
    #
    # @raise [InvalidFormat]
    #   Could not determine the Pickle version from the first two bytes of the
    #   IO stream.
    #
    # @api private
    #
    def self.infer_protocol_version(io)
      first_byte  = io.getbyte
      second_byte = io.getbyte

      if first_byte == 0x80
        second_byte # second byte after 0x80 is the protocol version number
      else
        if first_byte == 40 # skip the MARK opcode
          if    Protocol1::OPCODES.include?(second_byte) then 1
          elsif Protocol0::OPCODES.include?(second_byte) then 0
          else
            raise(InvalidFormat,"cannot infer version from second byte: #{second_byte}")
          end
        else
          if    Protocol1::OPCODES.include?(first_byte) then 1
          elsif Protocol0::OPCODES.include?(first_byte) then 0
          else
            raise(InvalidFormat,"cannot infer version from first byte: #{first_byte}")
          end
        end
      end
    ensure
      io.ungetbyte(second_byte)
      io.ungetbyte(first_byte)
    end
  end
end
