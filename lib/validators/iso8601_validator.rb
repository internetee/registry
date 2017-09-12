class Iso8601Validator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if options[:date_only]
      record.errors.add(attribute, :invalid_iso8601_date) unless value =~ date_format
    end
  end

  private

  def date_format
    /\d{4}-\d{2}-\d{2}/
  end
end
