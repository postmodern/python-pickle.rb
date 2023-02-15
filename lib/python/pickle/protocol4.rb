require 'python/pickle/protocol4'

module Python
  module Pickle
    class Protocol4 < Protocol3

      # Opcodes for Pickle protocol 4.
      #
      # @see https://peps.python.org/pep-3154/
      OPCODES = Protocol3::OPCODES + Set[
        140, # SHORT_BINUNICODE
        141, # BINUNICODE8
        142, # BINBYTES8
        143, # EMPTY_SET
        144, # ADDITEMS
        145, # FROZENSET
        146, # NEWOBJ_EX
        147, # STACK_GLOBAL
        148, # MEMOIZE
        149  # FRAME
      ]

    end
  end
end
