class SettingEntry < ApplicationRecord
  include Versions
  validates :code, presence: true, uniqueness: true
  validates :format, presence: true
  validates :group, presence: true
  validate :valid_value_format
  validates_format_of :code, with: /([a-z])[a-z|_]+[a-z]/

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

  # rubocop:disable Style/MethodMissingSuper
  # rubocop:disable Style/MissingRespondToMissing
  def self.method_missing(method, *args)
    super(method, *args)
  rescue NoMethodError
    get_or_set(method.to_s, args[0])
  end
  # rubocop:enable Style/MissingRespondToMissing
  # rubocop:enable Style/MethodMissingSuper

  def self.get_or_set(method_name, arg)
    if method_name[-1] == '='
      SettingEntry.find_by!(code: method_name.sub('=', '')).update(value: arg.to_s)
    else
      stg = SettingEntry.find_by(code: method_name)
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
