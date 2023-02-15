require 'python/pickle/protocol4'

module Python
  module Pickle
    class Protocol5 < Protocol4

      # Opcodes for Pickle protocol 5.
      #
      # @see https://peps.python.org/pep-0574/
      OPCODES = Protocol4::OPCODES + Set[
        150, # BYTEARRAY8
        151, # NEXT_BUFFER
        152, # READONLY_BUFFER
      ]
    end
  end
end
