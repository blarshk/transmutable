require 'transmutable/base'
require 'transmutable/transmutable_class_methods'

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
end