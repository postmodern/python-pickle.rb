require 'python/pickle/protocol1'

module Python
  module Pickle
    class Protocol2 < Protocol1

      # Opcodes for Pickle protocol version 2.
      #
      # @see https://github.com/python/cpython/blob/main/Lib/pickletools.py
      OPCODES = Protocol1::OPCODES + Set[
        128, # PROTO
        129, # NEWOBJ
        130, # EXT1
        131, # EXT2
        132, # EXT4
        133, # TUPLE1
        134, # TUPLE2
        135, # TUPLE3
        136, # NEWTRUE
        137, # NEWFALSE
        138, # LONG1
        139  # LONG4
      ]

    end
  end
end
