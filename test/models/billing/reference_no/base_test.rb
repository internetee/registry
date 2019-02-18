require 'test_helper'

# https://www.pangaliit.ee/settlements-and-standards/reference-number-of-the-invoice
class ReferenceNoBaseTest < ActiveSupport::TestCase
  def test_generates_random_base
    assert_not_equal Billing::ReferenceNo::Base.generate, Billing::ReferenceNo::Base.generate
  end

  def test_randomly_generated_base_conforms_to_standard
    base = Billing::ReferenceNo::Base.generate
    format = /\A\d{1,19}\z/
    assert_match format, base.to_s
  end

  def test_generates_check_digit_for_a_given_base
    assert_equal 3, Billing::ReferenceNo::Base.new('1').check_digit
    assert_equal 7, Billing::ReferenceNo::Base.new('1234567891234567891').check_digit
    assert_equal 0, Billing::ReferenceNo::Base.new('773423').check_digit
  end

  def test_returns_string_representation
    base = Billing::ReferenceNo::Base.new('1')
    assert_equal '1', base.to_s
  end

  def test_normalizes_non_string_values
    base = Billing::ReferenceNo::Base.new(1)
    assert_equal '1', base.to_s
  end
end
