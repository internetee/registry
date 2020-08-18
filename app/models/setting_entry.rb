class SettingEntry < ApplicationRecord
  include Versions
  validates :code, presence: true, uniqueness: true, format: { with: /\A([a-z])[a-z|_]+[a-z]\z/ }
  validates :format, presence: true
  validates :group, presence: true
  validate :validate_value_format
  validate :validate_code_is_not_using_reserved_name
  before_update :replace_boolean_nil_with_false

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
    return false if format == 'boolean' && value.blank?
    return if value.blank?

    send(method)
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

  # Hooks
  def replace_boolean_nil_with_false
    return unless format == 'boolean'

    self.value = value == 'true' ? 'true' : 'false'
  end

  def validate_code_is_not_using_reserved_name
    disallowed = []
    ActiveRecord::Base.instance_methods.sort.each { |m| disallowed << m.to_s }
    errors.add(:code, :invalid) if disallowed.include? code
  end

  def validate_value_format
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
