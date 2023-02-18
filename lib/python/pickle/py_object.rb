require 'python/pickle/py_class'

module Python
  module Pickle
    #
    # Represents a Python object.
    #
    class PyObject

      # The Python class of the Python object.
      #
      # @return [PyClass]
      attr_reader :py_class

      # The arguments used to initialize the Python object.
      #
      # @return [Array]
      attr_reader :init_args

      # The keyword arguments used to initialize the Python object.
      #
      # @return [Array]
      attr_reader :init_kwargs

      # The populated attributes of the Python object.
      #
      # @return [Hash{String => Object}]
      attr_reader :attributes

      #
      # Initializes the Python object.
      #
      # @param [PyClass] py_class
      #   The Python class of the Python object.
      #
      # @param [Array] args
      #   Additional arguments used to initialize the Python object.
      #
      # @param [Hash{Symbol => Object}] kwargs
      #   Additional keyword arguments used to initialize the Python object.
      #
      # @api private
      #
      def initialize(py_class,*args,**kwargs)
        @py_class    = py_class
        @init_args   = args
        @init_kwargs = kwargs

        @attributes = {}
      end

      #
      # Fetches the attribute of the Python object.
      #
      # @param [String] attribute
      #   The attribute name.
      #
      # @return [Object]
      #   The attributes value.
      #
      # @raise [ArgumentError]
      #   The Python object does not have an attribute of the given name.
      #
      # @example
      #   obj.getattr('x')
      #   # => 2
      #
      def getattr(attribute)
        @attributes.fetch(attribute) do
          raise(ArgumentError,"Python object has no attribute #{attribute.inspect}: #{self.inspect}")
        end
      end

      #
      # Sets an attribute in the Python object.
      #
      # @param [String] name
      #   The attribute name.
      #
      # @param [Object] value
      #   The new value for the attribute.
      #
      # @example
      #   obj.setattr('x',2)
      #   # => 2
      #
      def setattr(name,value)
        @attributes[name] = value
      end

      #
      # Sets the state of the Python object.
      #
      # @api private
      #
      def __setstate__(new_attributes)
        @attributes = new_attributes
      end

      #
      # Converts the Python object to a Hash.
      #
      # @return [Hash]
      #
      def to_h
        @attributes
      end

      protected

      #
      # Allows for direct access to attributes.
      #
      # @example
      #   obj.x = 2
      #   obj.x
      #   # => 2
      #
      def method_missing(method_name,*arguments,&block)
        if method_name.end_with?('=')
          attr = method_name[0..-2]

          if arguments.length == 1 && !block
            return @attributes[attr] = arguments[0]
          else
            super(method_name,*arguments,&block)
          end
        else
          attr = method_name.to_s

          if @attributes.has_key?(attr) && arguments.empty? && !block
            return @attributes[attr]
          else
            super(method_name,*arguments,&block)
          end
        end
      end

    end
  end
end
