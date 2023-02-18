require 'python/pickle/py_object'

module Python
  module Pickle
    #
    # Represents a Python class.
    #
    class PyClass

      # The namespace the Python class is defined within.
      #
      # @return [String]
      attr_reader :namespace

      # The name of the Python class.
      #
      # @return [String]
      attr_reader :name

      #
      # Initializes the Python class.
      #
      # @param [String, nil] namespace
      #   The namespace of the Python class.
      #
      # @param [String] name
      #   The name of the Python class.
      #
      # @api private
      #
      def initialize(namespace=nil,name)
        @namespace = namespace
        @name      = name
      end

      #
      # Initializes a new Python object from the Python class.
      #
      # @param [Array] args
      #   Additional `__init__` arguments.
      #
      # @param [Hash{Symbol => Object}] kwargs
      #   Additional `__init__` keyword arguments.
      #
      # @api private
      #
      def new(*args,**kwargs)
        PyObject.new(self,*args,**kwargs)
      end

      #
      # Converts the Python class into a String.
      #
      # @return [String]
      #
      def to_s
        if @namespace
          "#{@namespace}.#{@name}"
        else
          @name.to_s
        end
      end

      #
      # Inspects the Python object.
      #
      # @return [String]
      #
      def inspect
        "#<#{self.class}: #{self}>"
      end

    end
  end
end
