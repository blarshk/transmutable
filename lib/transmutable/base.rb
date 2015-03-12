module Transmutable
  class Base
    attr_accessor :model

    def self.add_to_transmute(*methods)
      define_method :transmute_addons do
        methods
      end
    end

    def self.remove_from_transmute(*methods)
      define_method :transmute_skips do
        methods
      end
    end

    def self.serialize_attrs(*methods)
      define_method :default_attrs do
        methods
      end
    end

    def initialize(model)
      @model = model
    end

    def transmute
      Hash[serialize_methods.map { |attribute| [attribute, model.send(attribute)] }]
    end

    private
      def serialize_methods
        default_attrs - transmute_skips + transmute_addons
      end

      def transmute_addons
        []
      end

      def transmute_skips
        []
      end

      def default_attrs
        # Guard clause for Rails-esque models
        return model.attributes.keys.map(&:to_sym) if model.respond_to? :attributes

        model.instance_variables
          .reject { |var| model.instance_variable_get(var).respond_to? :serialize }
          .map { |var| var.to_s.gsub('@', '').to_sym }
      end
  end
end