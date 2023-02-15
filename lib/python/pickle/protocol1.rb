require 'python/pickle/protocol0'

module Python
  module Pickle
    class Protocol1 < Protocol0

      # Opcodes for Pickle protocol version 1.
      #
      # @see https://github.com/python/cpython/blob/main/Lib/pickletools.py
      OPCODES = Set[
        40,  # MARK
        41,  # EMPTY_TUPLE
        46,  # STOP
        71,  # BINFLOAT
        73,  # INT
        75,  # BININT1
        76,  # LONG
        78,  # NONE
        82,  # REDUCE
        84,  # BINSTRING
        85,  # SHORT_BINSTRING
        88,  # BINUNICODE
        93,  # EMPTY_LIST
        98,  # BUILD
        99,  # GLOBAL
        101, # APPENDS
        113, # BINPUT
        116, # TUPLE
        117, # SETITEMS
        125  # EMPTY_DICT
      ]

    end
  end
end
