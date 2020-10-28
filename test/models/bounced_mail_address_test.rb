require 'test_helper'

class BouncedMailAddressTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  def setup
    @bounced_mail = BouncedMailAddress.new
    @bounced_mail.email = 'recipient@registry.test'
    @bounced_mail.message_id = '010f0174a0c7d348-ea6e2fc1-0854-4073-b71f-5cecf9b0d0b2-000000'
    @bounced_mail.bounce_type = 'Permanent'
    @bounced_mail.bounce_subtype = 'General'
    @bounced_mail.action = 'failed'
    @bounced_mail.status = '5.1.1'
    @bounced_mail.diagnostic =  'smtp; 550 5.1.1 user unknown'
  end

  def test_email_is_required
    assert @bounced_mail.valid?
    @bounced_mail.email = nil
    assert @bounced_mail.invalid?
  end

  def test_diagnostic_is_not_required
    assert @bounced_mail.valid?
    @bounced_mail.diagnostic = nil
    assert @bounced_mail.valid?
  end

  def test_bounce_reason_is_determined_dynamically
    assert @bounced_mail.valid?
    assert_equal 'failed (5.1.1 smtp; 550 5.1.1 user unknown)', @bounced_mail.bounce_reason
  end

  def test_creates_objects_from_sns_json
    BouncedMailAddress.record(sns_bounce_payload)

    bounced_mail = BouncedMailAddress.last
    assert_equal domains(:shop).registrant.email, bounced_mail.email
    assert_equal 'failed', bounced_mail.action
    assert_equal '5.1.1', bounced_mail.status
    assert_equal 'smtp; 550 5.1.1 user unknown', bounced_mail.diagnostic
  end

  def sns_bounce_payload
    {
      "notificationType": "Bounce",
      "mail": {
        "source": "noreply@registry.test",
        "sourceIp": "195.43.86.5",
        "messageId": "010f0174a0c7d348-ea6e2fc1-0854-4073-b71f-5cecf9b0d0b2-000000",
        "sourceArn": "arn:aws:ses:us-east-2:65026820000:identity/noreply@registry.test",
        "timestamp": "2020-09-18T10:34:44.000Z",
        "destination": [ "#{domains(:shop).registrant.email}" ],
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
            "emailAddress": "#{domains(:shop).registrant.email}",
            "diagnosticCode": "smtp; 550 5.1.1 user unknown"
          }
        ]
      }
    }.as_json
  end
end
