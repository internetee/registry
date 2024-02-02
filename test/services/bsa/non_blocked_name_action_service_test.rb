require 'test_helper'

BODY = {
  "registered": ['domain1.tld', 'domain2.tld', 'domain3.tld'],
  "reserved": ['domain4.tld', 'domain5.tld', 'domain6.tld'],
  "invalid": ['domain7.tld', 'domain8.tld', 'domain9.tld']
}

RESPONSE = {
  message: 'ok'
}

INVALID_RESPONSE = {
  "message": 'Unsupported Media Type',
  "description": 'The server is refusing to service the request because the entity of the request is in a format' \
                  ' not supported by the requested resource for the requested method'
}

class Bsa::NonBlockedNameActionServiceTest < ActiveSupport::TestCase
  setup do
    token = generate_test_bsa_token(Time.zone.now + 20.minute)
    stub_succesfull_request(token)
  end

  def test_for_succesfull_add_action
    stub_request(:post, 'https://api-ote.bsagateway.co/bsa/api/blockrsporder/nonblockednames?action=add&suborderid=1')
      .to_return(
        status: 202,
        body: RESPONSE.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    r = Bsa::NonBlockedNameActionService.call(action: 'add', suborder_id: 1, payload: BODY)

    assert r.result?
  end

  def test_for_failed_add_action
    stub_request(:post, 'https://api-ote.bsagateway.co/bsa/api/blockrsporder/nonblockednames?action=add&suborderid=1')
      .to_return(
        status: 415,
        body: INVALID_RESPONSE.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    r = Bsa::NonBlockedNameActionService.call(action: 'add', suborder_id: 1, payload: BODY)

    refute r.result?
    assert_equal r.error.message, 'Unsupported Media Type'
    assert_equal r.error.description, 'The server is refusing to service the request because the entity of the' \
                                       ' request is in a format not supported by the requested resource for the' \
                                       ' requested method'
  end

  def test_for_succesfull_remove_action
    stub_request(:post, 'https://api-ote.bsagateway.co/bsa/api/blockrsporder/nonblockednames?action=remove&suborderid=1')
      .to_return(
        status: 202,
        body: RESPONSE.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    r = Bsa::NonBlockedNameActionService.call(action: 'remove', suborder_id: 1, payload: BODY)

    assert r.result?
  end

  def test_for_failed_remove_action
    stub_request(:post, 'https://api-ote.bsagateway.co/bsa/api/blockrsporder/nonblockednames?action=remove&suborderid=1')
      .to_return(
        status: 415,
        body: INVALID_RESPONSE.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    r = Bsa::NonBlockedNameActionService.call(action: 'remove', suborder_id: 1, payload: BODY)

    refute r.result?
    assert_equal r.error.message, 'Unsupported Media Type'
    assert_equal r.error.description, 'The server is refusing to service the request because the entity of the' \
                                       ' request is in a format not supported by the requested resource for the' \
                                       ' requested method'
  end

  def test_for_succesfull_remove_all_action
    stub_request(:post, 'https://api-ote.bsagateway.co/bsa/api/blockrsporder/1/nonblockednames?action=remove')
      .to_return(
        status: 202,
        body: RESPONSE.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    r = Bsa::NonBlockedNameActionService.call(action: 'remove_all', suborder_id: 1, payload: BODY)

    assert r.result?
  end

  def test_for_failed_remove_all_action
    stub_request(:post, 'https://api-ote.bsagateway.co/bsa/api/blockrsporder/1/nonblockednames?action=remove')
      .to_return(
        status: 415,
        body: INVALID_RESPONSE.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    r = Bsa::NonBlockedNameActionService.call(action: 'remove_all', suborder_id: 1, payload: BODY)

    refute r.result?
    assert_equal r.error.message, 'Unsupported Media Type'
    assert_equal r.error.description, 'The server is refusing to service the request because the entity of the' \
                                       ' request is in a format not supported by the requested resource for the' \
                                       ' requested method'
  end

  def test_parse_query_parameters
    instance_serive = Bsa::NonBlockedNameActionService.new(action: 'remove', suborder_id: 1, payload: BODY)

    result = instance_serive.send(:query_string)
    assert_equal result, 'action=remove&suborderid=1'
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
