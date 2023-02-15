require 'python/pickle/protocol2'

module Python
  module Pickle
    class Protocol3 < Protocol2
      # Opcodes for Pickle protocol version 2.
      #
      # @see http://formats.kaitai.io/python_pickle/ruby.html
      OPCODES = Protocol2::OPCODES + Set[
        66, # BINBYTES
        67  # SHORT_BINBYTES
      ]
    end
  end
end
