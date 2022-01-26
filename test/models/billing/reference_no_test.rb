require 'test_helper'

class ReferenceNoTest < ActiveSupport::TestCase
  def test_returns_format_regexp
    format = /\A\d{2,20}\z/
    assert_equal format, Billing::ReferenceNo::REGEXP
  end

  def test_generated_reference_number_conforms_to_format
    stub_request(:post, "http://eis_billing_system:3000/api/v1/invoice_generator/reference_number_generator").
    with(
      body: "{\"initiator\":\"registry\"}",
      headers: {
      'Accept'=>'Bearer WA9UvDmzR9UcE5rLqpWravPQtdS8eDMAIynzGdSOTw==--9ZShwwij3qmLeuMJ--NE96w2PnfpfyIuuNzDJTGw==',
      'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'Authorization'=>'Bearer foobar',
      'Content-Type'=>'application/json',
      'User-Agent'=>'Ruby'
      }).
    to_return(status: 200, body: "{\"reference_number\":\"12332\"}", headers: {})

    reference_no = Billing::ReferenceNo.generate
    assert_match Billing::ReferenceNo::REGEXP, reference_no
  end
end
