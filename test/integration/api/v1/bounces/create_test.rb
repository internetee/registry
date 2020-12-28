require 'test_helper'

class BouncesApiV1CreateTest < ActionDispatch::IntegrationTest
  def setup
    @api_key = "Basic #{ENV['api_shared_key']}"
    @headers = { "Authorization": "#{@api_key}" }
    @json_body = { "data": valid_bounce_request }.as_json
  end

  def test_authorizes_api_request
    post api_v1_bounces_path, params: @json_body, headers: @headers
    assert_response :created

    invalid_headers = { "Authorization": "Basic invalid_api_key" }
    post api_v1_bounces_path, params: @json_body, headers: invalid_headers
    assert_response :unauthorized
  end

  def test_returns_bad_request_if_invalid_payload
    invalid_json_body = @json_body.dup
    invalid_json_body['data']['bounce']['bouncedRecipients'] = nil

    post api_v1_bounces_path, params: invalid_json_body, headers: @headers
    assert_response :bad_request

    invalid_json_body = 'aaaa'
    post api_v1_bounces_path, params: invalid_json_body, headers: @headers
    assert_response :bad_request
  end

  def test_saves_new_bounce_object
    request_body = @json_body.dup
    random_mail = "#{rand(10000..99999)}@registry.test"
    request_body['data']['bounce']['bouncedRecipients'][0]['emailAddress'] = random_mail

    post api_v1_bounces_path, params: request_body, headers: @headers
    assert_response :created

    bounced_mail = BouncedMailAddress.last
    assert bounced_mail.email = random_mail
    assert '5.1.1', bounced_mail.status
    assert 'failed', bounced_mail.action
  end

  def valid_bounce_request
    {
      "notificationType": "Bounce",
      "mail": {
        "source": "noreply@registry.test",
        "sourceIp": "195.43.86.5",
        "messageId": "010f0174a0c7d348-ea6e2fc1-0854-4073-b71f-5cecf9b0d0b2-000000",
        "sourceArn": "arn:aws:ses:us-east-2:65026820000:identity/noreply@registry.test",
        "timestamp": "2020-09-18T10:34:44.000Z",
        "destination": [ "bounced@registry.test" ],
        "sendingAccountId": "650268220000"
      },
      "bounce": {
        "timestamp": "2020-09-18T10:34:44.911Z",
        "bounceType": "Permanent",
        "feedbackId": "010f0174a0c7d4f9-27d59756-6111-4d5f-xxxx-26bee0d55fa2-000000",
        "remoteMtaIp": "127.0.01",
        "reportingMTA": "dsn; xxx.amazonses.com",
        "bounceSubType": "General",
        "bouncedRecipients": [
          {
            "action": "failed",
            "status": "5.1.1",
            "emailAddress": "bounced@registry.test",
            "diagnosticCode": "smtp; 550 5.1.1 user unknown"
          }
        ]
      }
    }.as_json
  end
end
