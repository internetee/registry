class UniquenessMultiValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    validated = []
    list = value.reject(&:marked_for_destruction?)
    list.each do |x|
      next if x.send(options[:attribute]).blank?
      existing = list.select { |y| x.send(options[:attribute]) == y.send(options[:attribute]) }
      next unless existing.length > 1
      validated << x.send(options[:attribute])
      record.errors.add(attribute, :invalid) if record.errors[attribute].blank?
      x.errors.add(options[:attribute], :taken)
    end
  end
end
