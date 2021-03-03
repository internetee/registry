require 'test_helper'

class DateTimeIso8601Validatable
  include ActiveModel::Validations
  validates_with DateTimeIso8601Validator, :attributes=>[:errors]
  attr_accessor :code, :type
  validates :code, iso8601: { date_only: true }, if: :birthday?

  def birthday?
    type == "birthday"
  end

  def empty?
    code.empty?
  end
end

class DateTimeIso8601ValidatorTest < ActiveSupport::TestCase
  def test_check_invalid_reverse_date
    obj = DateTimeIso8601Validatable.new
    obj.type = "birthday"
    obj.code = "22-12-2020"
    assert_not obj.valid?
  end

  def test_check_date_without_separate_symbols
    obj = DateTimeIso8601Validatable.new
    obj.type = "birthday"
    obj.code = "24521012"
    assert_not obj.valid?
  end

  def test_check_empty_date
    obj = DateTimeIso8601Validatable.new
    obj.type = "birthday"
    obj.code = ""
    assert_not obj.valid?
  end

  def test_check_valid_date
    obj = DateTimeIso8601Validatable.new
    obj.code = Date.new(2000,5,25).iso8601
    obj.type = "birthday"
    assert obj.valid?
  end

  def test_return_code_2005_in_epp_validate
    obj = DateTimeIso8601Validatable.new
    obj.code = Date.new(2000,5,25).iso8601
    obj.type = "birthday"
    epp_resp = DateTimeIso8601Validator.validate_epp(obj, obj.code)
    assert_equal epp_resp[:msg], "Expiry absolute must be compatible to ISO 8601"
  end

  def test_epp_request_with_empty_data
    obj = DateTimeIso8601Validatable.new
    obj.code = ""
    obj.type = "birthday"
    epp_resp = DateTimeIso8601Validator.validate_epp(obj, obj.code)
    assert_nil epp_resp
  end
end