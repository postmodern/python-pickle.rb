module Python
  module Pickle
    class Error < RuntimeError
    end

    class InvalidFormat < Error
    end

    class DeserializationError < Error
    end
  end
end
