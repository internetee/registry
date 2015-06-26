class ObjectCountValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    min, max = options[:min].call, options[:max].call
    return if value.count { |i| !i.marked_for_destruction? }.between?(min, max)
    association = options[:association] || attribute
    record.errors.add(association, :out_of_range, { min: min, max: max })
  end
end
