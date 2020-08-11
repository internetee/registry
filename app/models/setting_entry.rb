class SettingEntry < ApplicationRecord
  validates :code, presence: true, uniqueness: true
  validates :value, presence: true
  validates :format, presence: true
  validate :valid_value_format

  VALUE_FORMATS = {
    string: :string_format,
    integer: :integer_format,
    boolean: :boolean_format,
    hash: :hash_format,
    array: :array_format,
  }.with_indifferent_access.freeze

  def valid_value_format
    formats = VALUE_FORMATS.with_indifferent_access
    errors.add(:format, :invalid) unless formats.keys.any? format
  end

  def string_format
    value
  end

  def integer_format
    value.to_i
  end

  def boolean_format
    value == 'true'
  end

  def hash_format
    JSON.parse(value)
  end

  def array_format
    JSON.parse(value).to_a
  end

  def retrieve
    method = VALUE_FORMATS[format]
    send(method)
  end

  def self.method_missing(method, *args)
    super(method, *args)
  rescue NoMethodError
    raise NoMethodError if method.to_s.include? '='

    SettingEntry.find_by!(code: method.to_s).retrieve
  end
end
