require 'test_helper'

class DurationIso8601Validatable
  include ActiveModel::Validations
  validates_with DurationIso8601Validator, :attributes=>[:errors]
  attr_accessor :duration
  validates :duration, inclusion: { in: Proc.new { |price| price.class.durations } }

  def self.durations
    [
      '3 mons',
      '6 mons',
      '9 mons',
      '1 year',
      '2 years',
      '3 years',
      '4 years',
      '5 years',
      '6 years',
      '7 years',
      '8 years',
      '9 years',
      '10 years',
    ]
  end

  def empty?
    duration.empty?
  end
end

class DurationIso8601ValidatorTest < ActiveSupport::TestCase
    def test_valid_duration
        dura = DurationIso8601Validatable.new
        dura.duration = '1 year'
        assert dura.valid?
    end

    def test_invalid_duration
        dura = DurationIso8601Validatable.new
        dura.duration = 'one millinons years'
        assert_not dura.valid?
    end

    def test_empty_duration
        dura = DurationIso8601Validatable.new
        dura.duration = ''
        assert_not dura.valid?
    end

    def test_return_epp_response_code_2005
        dura = DurationIso8601Validatable.new
        dura.duration = '1 year'
        epp_resp = DurationIso8601Validator.validate_epp(dura, dura.duration)
        assert_equal epp_resp[:msg], "Expiry relative must be compatible to ISO 8601"
    end
end
