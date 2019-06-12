require 'test_helper'

class IbanTest < ActiveSupport::TestCase
  def test_returns_max_length
    assert_equal 34, Iban.max_length
  end
end