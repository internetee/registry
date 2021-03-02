require 'test_helper'

class DateTimeIso8601Validatable
  include ActiveModel::Validations
  validates_with DateTimeIso8601Validator, :attributes=>[:code]
  attr_accessor :code
  validates :code, iso8601: { date_only: true }
end

class DateTimeIso8601ValidatorTest < ActiveSupport::TestCase
  def test_check_invalid_date
    obj = DateTimeIso8601Validatable.new
    obj.code = "22-12-2020"
    assert_not obj.valid?
  end
end