module Python
  module Pickle
    #
    # Represents a Python `tuple` object.
    #
    class Tuple < Array

      #
      # Inspects the tuple.
      #
      # @return [String]
      #
      def inspect
        "#<#{self.class}: #{super}>"
      end

    end
  end
end
