require 'test_helper'

RESPONSE_BLOCK_VIEW_SERVICE_FOR_JOB = {
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
}.freeze

EMPTY_RESPONSE_BLOCK_VIEW_SERVICE_FOR_JOB = {
  "list": [],
    "offset": 0,
    "limit": 100,
    "count": 0,
    "total": 0,
  "sortBy": [
    'createdDt'
  ],
  "order": 'asc'
}

INVALID_RESPONSE = {
  "message": 'Unsupported Media Type',
  "description": 'The server is refusing to service the request because the entity of the request is in a format' \
                 ' not supported by the requested resource for the requested method'
}.freeze

class FetchGodaddyBsaBlockOrderListJobTest < ActiveSupport::TestCase
  setup do
    token = generate_test_bsa_token(Time.zone.now + 20.minute)
    stub_succesfull_auth_request(token)
  end

  def test_succesfull_fetch_block_order_list_and_added_to_db
    stub_request(:get, 'https://api-ote.bsagateway.co/bsa/api/blockrsporder?limit=20&offset=0&q=blockOrderStatus.name=QueuedForActivation')
      .to_return(
        status: 200,
        body: RESPONSE_BLOCK_VIEW_SERVICE_FOR_JOB.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    assert_difference 'BsaProtectedDomain.count', 2 do
      FetchGodaddyBsaBlockOrderListJob.perform_now
    end
  end

  def test_should_show_message_if_list_is_empty
    stub_request(:get, 'https://api-ote.bsagateway.co/bsa/api/blockrsporder?limit=20&offset=0&q=blockOrderStatus.name=QueuedForActivation')
      .to_return(
        status: 200,
        body: EMPTY_RESPONSE_BLOCK_VIEW_SERVICE_FOR_JOB.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    result = FetchGodaddyBsaBlockOrderListJob.perform_now

    assert_equal result, 'Limit reached. No more block orders to fetch'
  end

  def test_should_show_message_if_error_occur
    stub_request(:get, 'https://api-ote.bsagateway.co/bsa/api/blockrsporder?limit=20&offset=0&q=blockOrderStatus.name=QueuedForActivation')
    .to_return(
      status: 415,
      body: INVALID_RESPONSE.to_json,
      headers: { 'Content-Type' => 'application/json' }
    )

    result = FetchGodaddyBsaBlockOrderListJob.perform_now

    assert_equal result[:message], 'Unsupported Media Type'
    assert_equal result[:description], 'The server is refusing to service the request because the entity of the' \
                                       ' request is in a format not supported by the requested resource for the' \
                                       ' requested method'
  end

  private

  def stub_succesfull_auth_request(token)
    stub_request(:post, 'https://api-ote.bsagateway.co/iam/api/authenticate/apiKey')
      .to_return(
        status: 200,
        body: { id_token: token }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
  end
end
