require 'test_helper'

BODY_ORDER_STATUS_SETTING = [
  { blockSubOrderId: 1, status: 'ActivationInProgress' },
  { blockSubOrderId: 2, status: 'ActivationInProgress' },
  { blockSubOrderId: 4, status: 'Active' },
  { blockSubOrderId: 5, status: 'ReleaseInProgress' },
  { blockSubOrderId: 6, status: 'Closed' }
]

RESPONSE_ORDER_STATUS_SETTING = {
  message: 'ok'
}

INVALID_RESPONSE = {
  "message": 'Unsupported Media Type',
  "description": 'The server is refusing to service the request because the entity of the request is in a format' \
                  ' not supported by the requested resource for the requested method'
}

class Bsa::BlockOrderListServiceTest < ActiveSupport::TestCase
  setup do
    token = generate_test_bsa_token(Time.zone.now + 20.minute)
    stub_succesfull_request(token)
  end

  def test_for_succesfull_update_statuses
    stub_request(:post, 'https://api-ote.bsagateway.co/bsa/api/blockrsporder/status')
      .to_return(
        status: 200,
        body: RESPONSE_ORDER_STATUS_SETTING.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    r = Bsa::BlockOrderStatusSettingService.call(payload: BODY_ORDER_STATUS_SETTING)

    assert r.result?
  end

  def test_for_failed_update_statuses
    stub_request(:post, 'https://api-ote.bsagateway.co/bsa/api/blockrsporder/status')
      .to_return(
        status: 415,
        body: INVALID_RESPONSE.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    r = Bsa::BlockOrderStatusSettingService.call(payload: BODY_ORDER_STATUS_SETTING)

    refute r.result?
    assert_equal r.error.message, 'Unsupported Media Type'
    assert_equal r.error.description, 'The server is refusing to service the request because the entity of the' \
                                       ' request is in a format not supported by the requested resource for the' \
                                       ' requested method'
  end

  private

  def stub_succesfull_request(token)
    stub_request(:post, 'https://api-ote.bsagateway.co/iam/api/authenticate/apiKey')
      .to_return(
        status: 200,
        body: { id_token: token }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
  end
end
