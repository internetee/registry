require 'test_helper'

class UpdateGodaddyDomainsStatusJobTest < ActiveSupport::TestCase
  BODY_ORDER_STATUS_SETTING_JOB = [
    { blockSubOrderId: 1, status: 'ActivationInProgress' },
    { blockSubOrderId: 2, status: 'ActivationInProgress' },
  ]
  
  RESPONSE_ORDER_STATUS_SETTING_JOB = {
    message: 'ok'
  }
  
  INVALID_RESPONSE = {
    "message": 'Unsupported Media Type',
    "description": 'The server is refusing to service the request because the entity of the request is in a format' \
                    ' not supported by the requested resource for the requested method'
  }
  
  setup do
    token = generate_test_bsa_token(Time.zone.now + 20.minute)
    stub_succesfull_auth_request(token)
  end

  def test_should_update_statuses
    stub_request(:post, 'https://api-ote.bsagateway.co/bsa/api/blockrsporder/status')
    .to_return(
      status: 200,
      body: BODY_ORDER_STATUS_SETTING_JOB.to_json,
      headers: { 'Content-Type' => 'application/json' }
    )

    assert BsaProtectedDomain.all.all? { |domain| domain.state == 'QueuedForActivation' }

    UpdateGodaddyDomainsStatusJob.perform_now('QueuedForActivation', 'ActivationInProgress')

    assert BsaProtectedDomain.all.all? { |domain| domain.state == 'ActivationInProgress' }
  end

  def test_should_return_reason_of_error_and_not_update_statuses
    stub_request(:post, 'https://api-ote.bsagateway.co/bsa/api/blockrsporder/status')
    .to_return(
      status: 415,
      body: INVALID_RESPONSE.to_json,
      headers: { 'Content-Type' => 'application/json' }
    )

    assert BsaProtectedDomain.all.all? { |domain| domain.state == 'QueuedForActivation' }
    result = UpdateGodaddyDomainsStatusJob.perform_now('QueuedForActivation', 'ActivationInProgress')

    assert BsaProtectedDomain.all.all? { |domain| domain.state == 'QueuedForActivation' }
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
