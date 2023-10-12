require 'test_helper'

RESPONSE = {
  "list": [
  "label1",
  "label2",
  "label3",
  "label4",
  "label5"
  ],
  "offset": 0,
  "limit": 5,
  "count": 5,
  "total": 12
 }

 INVALID_RESPONSE = {
  "message": 'Unsupported Media Type',
  "description": 'The server is refusing to service the request because the entity of the request is in a format' \
                  ' not supported by the requested resource for the requested method'
}

class Bsa::BlockOrderViewServiceTest < ActiveSupport::TestCase
  setup do
    token = generate_test_bsa_token(Time.zone.now + 20.minute)
    stub_succesfull_request(token)
  end

  def test_for_succesfull_block_order_list
    stub_request(:get, 'https://api-ote.bsagateway.co/bsa/api/blockrsporder/labels?blocksuborderid=1')
      .to_return(
        status: 200,
        body: RESPONSE.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    r = Bsa::BlockOrderViewService.call(block_suborder_id: 1)

    assert r.result?
    assert_equal r.body.list.count, 5
    assert_equal r.body.list.first, 'label1'
  end

  def test_for_failed_block_order_list
    stub_request(:get, 'https://api-ote.bsagateway.co/bsa/api/blockrsporder/labels?blocksuborderid=1')
      .to_return(
        status: 415,
        body: INVALID_RESPONSE.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    r = Bsa::BlockOrderViewService.call(block_suborder_id: 1)

    refute r.result?
    assert_equal r.error.message, 'Unsupported Media Type'
    assert_equal r.error.description, 'The server is refusing to service the request because the entity of the' \
                                       ' request is in a format not supported by the requested resource for the' \
                                       ' requested method'
  end

  def test_parse_query_parameters
    instance_serive = Bsa::BlockOrderViewService.new(block_suborder_id: 1, offset: 10, limit: 2)

    result = instance_serive.send(:query_string)
    assert_equal result, 'blocksuborderid=1&offset=10&limit=2'
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