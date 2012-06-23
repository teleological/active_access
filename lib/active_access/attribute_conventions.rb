
require 'active_model'

module ActiveAccess
  class AttributeConventions

    MethodMatcher = ActiveModel::AttributeMethods::ClassMethods::
      AttributeMethodMatcher

    READ_MATCHERS = [
      MethodMatcher.new, # "plain" reader
      MethodMatcher.new(suffix: '_changed?'),
      MethodMatcher.new(suffix: '_change'),
      MethodMatcher.new(suffix: '_was'),
      MethodMatcher.new(suffix: '_before_type_cast'),
      MethodMatcher.new(prefix: '_'),
      MethodMatcher.new(prefix: '?')
    ]

    WRITE_MATCHERS = [
      MethodMatcher.new(prefix: 'reset_', suffix: '!'),
      MethodMatcher.new(suffix: '_will_change'),
      MethodMatcher.new(suffix: '=')
    ]

    class << self

      def reader_names(attr)
        READ_MATCHERS.map { |matcher| matcher.method_name(attr) }
      end

      def writer_names(attr)
        WRITE_MATCHERS.map { |matcher| matcher.method_name(attr) }
      end

    end

  end
end

