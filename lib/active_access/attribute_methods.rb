
require 'active_support/core_ext'

module ActiveAccess
  module AttributeMethods

    extend ActiveSupport::Concern

    included do
      class_attribute :_attribute_access, :instance_writer => false
      self._attribute_access = {}
    end

    module ClassMethods

      def attr_private(*attrs)
        update_attribute_method_access(:private, attrs)
      end

      def attr_private_writer(*attrs)
        update_attribute_method_access(:readonly, attrs)
      end

      def define_attribute_methods(attrs=nil)
        if defined?(ActiveRecord) && (self < ActiveRecord::AttributeMethods)
          super() # takes no arguments
          reset_attribute_method_access
        else
          super # takes a list of attribute names as arguments
          reset_attribute_method_access(attrs)
        end
      end

      private

      def update_attribute_method_access(level, attrs)
        self._attribute_access = self._attribute_access.dup
        attrs.each do |attr|
          self._attribute_access[attr.to_sym] = level
        end
        reset_attribute_method_access(attrs)
      end

      def reset_attribute_method_access(attrs=nil)

        if attrs
          attr_syms = attrs.map(&:to_sym)
          attr_accesses = _attribute_access.slice(*attr_syms)
        else
          attr_accesses = _attribute_access
        end

        attr_accesses.each do |attr, access|
          if [:private, :readonly].include?(access)
            privatize_attribute_writers(attr)
          end
          privatize_attribute_readers(attr) if access == :private
        end

      end

      def privatize_attribute_writers(attr)
        AttributeConventions.writer_names(attr).each do |name|
          private name if method_defined?(name)
        end
      end

      def privatize_attribute_readers(attr)
        AttributeConventions.reader_names(attr).each do |name|
          private name if method_defined?(name)
        end
      end

    end

  end
end

