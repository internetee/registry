require 'test_helper'

class ReferenceNoTest < ActiveSupport::TestCase
  def test_returns_format_regexp
    format = /\A\d{2,20}\z/
    assert_equal format, Billing::ReferenceNo::REGEXP
  end

  def test_generated_reference_number_conforms_to_format
    if Feature.billing_system_integrated?
      stub_request(:post, "http://eis_billing_system:3000/api/v1/invoice_generator/reference_number_generator")
        .to_return(status: 200, body: "{\"reference_number\":\"12332\"}", headers: {})

      reference_no = Billing::ReferenceNo.generate
      assert_match Billing::ReferenceNo::REGEXP, reference_no
    end
  end
end
