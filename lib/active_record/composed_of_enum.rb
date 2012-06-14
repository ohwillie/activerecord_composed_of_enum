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

      base.class_attribute(
        enum_column,
        :instance_reader => false,
        :instance_reader => false
      )

      enumeration = options[:enumeration]

      enumeration.each_with_index do |enum, cd|
        enum.send(:"#{enum_column}=", cd)
      end

      validates(
        enum_column,
        :presence => true,
        :inclusion => 0...enumeration.size
      )

      if options.has_key?(:default)
        after_initialize do
          send(:"#{part}=", options[:default]) unless send(part).present?
        end
      end

      composed_of(
        part,
        :class_name => base.name,
        :mapping => [enum_column.to_s],
        :constructor => lambda { |cd| cd.present? ? enumeration[cd] : nil }
      )
    end
  end
end
