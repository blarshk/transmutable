module Transmutable
  def self.included(base)
    base.extend(TransmutableClassMethods)

    add_default_transmuter_to(base)
  end

  def self.add_default_transmuter_to(base)
    base.class_eval do
      transmuter Base
    end
  end

  def serialize
    transmuter.new(self).transmute
  end

  def serialize_with(*relations)
    return_hash = serialize

    relations.each do |relation|
      case relation
        when String, Symbol
          serialize_val(relation, return_hash, send(relation))
        when Hash
          relation.each do |key, values|
            relation_val = send(key)

            if relation_val.respond_to?(:each) && !relation_val.is_a?(Hash)
              relation_val.each do |rel_val|
                if return_hash[key].present?
                  return_hash[key] << rel_val.serialize_with(*values)
                else
                  return_hash[key] = [rel_val.serialize_with(*values)]
                end
              end
            else
              return_hash[key] = relation_val.serialize_with(*values)
            end
          end
      end
    end

    return_hash
  end

  def serialize_val(key, return_hash, value)
    return return_hash[key] = {} if value.nil?

    if value.respond_to?(:each) && !value.is_a?(Hash)
      return_hash[key] = value.collect do |val|
        if val.respond_to? :serialize
          return_hash[key] = val.serialize
        else
          {}
        end
      end
    else
      return_hash[key] = value.serialize
    end
  end

  module TransmutableClassMethods
    def transmuter(transmuter_class)
      class_eval do
        define_method :transmuter do
          transmuter_class
        end
      end
    end
  end

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
        model.instance_variables
          .reject { |var| model.instance_variable_get(var).respond_to? :serialize }
          .map { |var| var.to_s.gsub('@', '').to_sym }
      end
  end
end