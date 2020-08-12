class SettingEntry < ApplicationRecord
  validates :code, presence: true, uniqueness: true
  validates :format, presence: true
  validates :group, presence: true
  validate :valid_value_format
  include Concerns::Settings::Migratable

  VALUE_FORMATS = {
    string: :string_format,
    integer: :integer_format,
    float: :float_format,
    boolean: :boolean_format,
    hash: :hash_format,
    array: :array_format,
  }.with_indifferent_access.freeze

  def retrieve
    method = VALUE_FORMATS[format]
    value.blank? ? nil : send(method)
  end

  def self.with_group(group_name)
    SettingEntry.order(id: :asc).where(group: group_name)
  end

  def self.method_missing(method, *args)
    super(method, *args)
  rescue NoMethodError
    if method.to_s[-1] == "="
      stg_code = method.to_s.sub("=", "")
      stg_value = args[0].to_s
      SettingEntry.find_by!(code: stg_code).update(value: stg_value)
    else
      stg = SettingEntry.find_by(code: method.to_s)
      stg ? stg.retrieve : nil
    end
  end

  # Validators
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

  def float_format
    value.to_f
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
end
