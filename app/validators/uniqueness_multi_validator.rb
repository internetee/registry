class UniquenessMultiValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    validated = []
    list = value.reject(&:marked_for_destruction?)
    list.each do |x|
      next if x.send(options[:attribute]).blank?

      existing = list.select { |y| x.send(options[:attribute]) == y.send(options[:attribute]) }
      next unless existing.length > 1

      validated << x.send(options[:attribute])
      association = options[:association] || attribute
      record.errors.add(association, :invalid) if record.errors[association].blank?
      x.errors.add(options[:attribute], :taken)
    end
  end
end
