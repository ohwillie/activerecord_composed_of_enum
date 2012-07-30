require 'require_relative'

require_relative 'composed_of_enum/version'

module ActiveRecord
  module ComposedOfEnum
    def composed_of_enum(part, options = {})
      unless options.has_key?(:base)
        raise ArgumentError, 'must provide :base option'
      end

      unless options.has_key?(:enumeration)
        raise ArgumentError, 'must provide :enumeration option'
      end

      base = options[:base]
      enum_column = :"#{part}_cd"

      base.class_attribute(enum_column, :instance_accessor => false)

      enumeration = options[:enumeration]

      enumeration.each_with_index do |enum, cd|
        enum.send(:"#{enum_column}=", cd)
      end

      validates(
        enum_column,
        :presence => true,
        :inclusion => 0...enumeration.size
      )

      setter_method_name = :"#{part}="

      if options.has_key?(:default)
        after_initialize do
          send(setter_method_name, options[:default]) unless send(part).present?
        end
      end

      define_method(setter_method_name) { |enum| self[enum_column] = enum.send(enum_column) }

      define_method(part) do
        enum_cd = self[enum_column]
        enum_cd.present? ? enumeration[enum_cd] : nil
      end
    end
  end
end
