module Python
  module Pickle
    class Error < RuntimeError
    end

    class InvalidFormat < Error
    end
  end
end
