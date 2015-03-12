module Transmutable  
  module TransmutableClassMethods
    def transmuter(transmuter_class)
      class_eval do
        define_method :transmuter do
          transmuter_class
        end
      end
    end
  end
end