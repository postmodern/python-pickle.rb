require 'python/pickle/instruction'

module Python
  module Pickle
    module Instructions
      class Dict < Instruction

        def initialize
          super(:DICT)
        end

      end

      DICT = Dict.new
    end
  end
end
