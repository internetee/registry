require 'test_helper'

RESPONSE = {
  "list": [
    {
      "blockSubOrderId": 690_680_666_563_633,
      "rspAccountId": 1005,
      "blockOrder": {
        "blockOrderId": 3_363_656_660_861
      },
      "blockOrderStatus": {
        "blockOrderStatusId": 2,
        "name": 'QueuedForActivation',
        "displayName": 'Queued for Activation',
        "description": 'Queued for Activation'
      },
      "productType": 'Standard',
      "tld": {
        "tldId": 22,
        "name": 'TEST-ONE',
        "displayName": '.test-one'
      },
      "label": 'testandvalidate',
      "createdDt": '2023-04-05T03:49:19.000+0000'
    },
    {
      "blockSubOrderId": 790_681_879_713_707,
      "rspAccountId": 1005,
      "blockOrder": {
        "blockOrderId": 7_073_179_781_861
      },
      "blockOrderStatus": {
        "blockOrderStatusId": 2,
        "name": 'QueuedForActivation',
        "displayName": 'Queued for Activation',
        "description": 'Queued for Activation'
      },
      "productType": 'Plus',
      "tld": {
        "tldId": 21,
        "name": 'TEST-TWO',
        "displayName": '.test-two'
      },
      "label": ' testandvalidate',
      "createdDt": '2023-04-19T04:48:29.000+0000'
    }
  ],
  "offset": 0,
  "limit": 100,
  "count": 2,
  "total": 2,
  "sortBy": [
    'createdDt'
  ],
  "order": 'asc'
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

  def test_for_succesfull_block_order_list
    stub_request(:get, 'https://api-ote.bsagateway.co/bsa/api/blockrsporder')
      .to_return(
        status: 200,
        body: RESPONSE.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    r = Bsa::BlockOrderListService.call

    assert r.result?
    assert_equal r.body.list.count, 2
  end

  def test_for_failed_block_order_list
    stub_request(:get, 'https://api-ote.bsagateway.co/bsa/api/blockrsporder')
      .to_return(
        status: 415,
        body: INVALID_RESPONSE.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    r = Bsa::BlockOrderListService.call

    refute r.result?
    assert_equal r.error.message, 'Unsupported Media Type'
    assert_equal r.error.description, 'The server is refusing to service the request because the entity of the' \
                                       ' request is in a format not supported by the requested resource for the' \
                                       ' requested method'
  end

  def test_parse_query_parameters
    instance_serive = Bsa::BlockOrderListService.new(sort_by: 'createdAt', order: 'desc', offset: 0, limit: 100, q: { 'tld' => 'test' })

    result = instance_serive.send(:query_string)

    assert_equal result, 'sortBy=createdAt&order=desc&offset=0&limit=100&tld=test'
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
