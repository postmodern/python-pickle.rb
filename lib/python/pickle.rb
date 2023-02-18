require 'python/pickle/protocol0'
require 'python/pickle/protocol1'
require 'python/pickle/protocol2'
require 'python/pickle/protocol3'
require 'python/pickle/protocol4'
require 'python/pickle/protocol5'
require 'python/pickle/exceptions'
require 'python/pickle/deserializer'
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
    DEFAULT_PROTOCOL = 4

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
    #   The explicit protocol version to use. If `nil` the protocol version will
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
    #   The explicit protocol version to use. If `nil` the protocol version will
    #   be inferred by inspecting the first two bytes of the stream.
    #
    # @param [Hash{Symbol => Object}] kwargs
    #   Additional keyword arguments.
    #
    # @option kwargs [Hash{Integer => Object}] :extensions
    #   A Hash of registered extension IDs and their Objects.
    #
    # @option kwargs [Hash{String => Hash{String => Class,Method}}] :constants
    #   An optional mapping of custom Python constant names to Ruby classes
    #   or methods.
    #
    # @option kwargs [Enumerable, nil] :buffers
    #   An enumerable list of out-of-band buffers.
    #
    # @api public
    #
    def self.load(data, protocol: nil, **kwargs)
      deserializer = Deserializer.new(**kwargs)

      parse(data, protocol: protocol) do |instruction|
        status, object = deserializer.execute(instruction)

        if status == :halt
          return object
        end
      end

      raise(DeserializationError,"failed to deserialize any object data from stream")
    end

    #
    # Deserializes a Python Pickle file.
    #
    # @param [String] path
    #   The path of the file.
    #
    # @param [Hash{Symbol => Object}] kwargs
    #   Additional keyword arguments.
    #
    # @option kwargs [Hash{Integer => Object}] :extensions
    #   A Hash of registered extension IDs and their Objects.
    #
    # @option kwargs [Hash{String => Hash{String => Class,Method}}] :constants
    #   An optional mapping of custom Python constant names to Ruby classes
    #   or methods.
    #
    # @option kwargs [Enumerable, nil] :buffers
    #   An enumerable list of out-of-band buffers.
    #
    # @return [Object]
    #   The deserialized object.
    #
    def self.load_file(path,**kwargs)
      result = nil

      File.open(path,'rb') do |file|
        result = load(file,**kwargs)
      end

      return result
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
    # @note serializing is currently not supported.
    #
    # @api public
    #
    def self.dump(object,output=nil, protocol: DEFAULT_PROTOCOL)
      raise(NotImplementedError,"pickle serializing is currently not supported")
    end

    #
    # Infers the protocol version from the IO stream.
    #
    # @param [IO] io
    #   The IO stream to inspect.
    #
    # @return [Integer]
    #   The inferred Python Pickle protocol version.
    #
    # @raise [InvalidFormat]
    #   Could not determine the Pickle version from the first two bytes of the
    #   IO stream.
    #
    # @api private
    #
    def self.infer_protocol_version(io)
      opcode = io.getbyte

      begin
        case opcode
        when 0x80 # PROTO (added in protocol 2)
          version = io.getbyte
          io.ungetbyte(version)
          return version
        when 48,  # POP (protocol 0)
             50,  # DUP (protocol 0)
             70,  # FLOAT (protocol 0)
             83,  # STRING (protocol 0)
             86,  # UNICODE (protocol 0)
             100, # DICT (protocol 0)
             103, # GET (protocol 0)
             108, # LIST (protocol 0)
             112  # PUT (protocol 0)
          0
        when 41,  # EMPTY_TUPLE (protocol 1)
             71,  # BINFLOAT (protocol 1)
             75,  # BININT1 (protocol 1)
             84,  # BINSTRING (protocol 1)
             85,  # SHORT_BINSTRING (protocol 1)
             88,  # BINUNICODE (protocol 1)
             93,  # EMPTY_LIST (protocol 1)
             101, # APPENDS (protocol 1)
             113, # BINPUT (protocol 1)
             117, # SETITEMS (protocol 1)
             125  # EMPTY_DICT (protocol 1)
          1
        when 46 # STOP
          # if we've read all the way to the end of the stream and still cannot
          # find any protocol 0 or protocol 1 specific opcodes, assume protocol 0
          0
        when 73, # INT  (identical in both protocol 0 and 1)
             76  # LONG (identical in both protocol 0 and 1)
          chars = io.gets

          begin
            infer_protocol_version(io)
          ensure
            chars.each_byte.reverse_each { |b| io.ungetbyte(b) }
          end
        when 40,  # MARK    (identical in both protocol 0 and 1)
             78,  # NONE    (identical in both protocol 0 and 1)
             82,  # REDUCE  (identical in both protocol 0 and 1)
             97,  # APPEND  (identical in both protocol 0 and 1)
             98,  # BUILD   (identical in both protocol 0 and 1)
             115, # SETITEM (identical in both protocol 0 and 1)
             116  # TUPLE   (identical in both protocol 0 and 1)
          infer_protocol_version(io)
        when 99 # GLOBAL
          first_nl_string  = io.gets
          second_nl_string = io.gets

          begin
            infer_protocol_version(io)
          ensure
            # push the read bytes back into the IO stream
            second_nl_string.each_byte.reverse_each { |b| io.ungetbyte(b) }
            first_nl_string.each_byte.reverse_each  { |b| io.ungetbyte(b) }
          end
        else
          raise(InvalidFormat,"cannot infer protocol version from opcode (#{opcode.inspect}) at position #{io.pos}")
        end
      ensure
        io.ungetbyte(opcode)
      end
    end
  end
end
