require 'test_helper'

class SendDataToDirectoTest < ActiveSupport::TestCase
  setup do
    Spy.on_instance_method(EisBilling::BaseController, :authorized).and_return(true)
  end

  def test_should_send_data_to_billing_directo
    stub_request(:post, "https://eis_billing_system:3000/api/v1/directo/directo").
    to_return(status: 200, body: "ok", headers: {})

    res = EisBilling::SendDataToDirecto.send_request(object_data: [], monthly: true, dry: true)
    assert_equal res.body, "ok"
  end
end
