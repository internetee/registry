require 'test_helper'

class ReferenceNoTest < ActiveSupport::TestCase
  def test_returns_format_regexp
    format = /\A\d{2,20}\z/
    assert_equal format, Billing::ReferenceNo::REGEXP
  end

  def test_generated_reference_number_conforms_to_format
    reference_no = Billing::ReferenceNo.generate
    assert_match Billing::ReferenceNo::REGEXP, reference_no
  end
end
