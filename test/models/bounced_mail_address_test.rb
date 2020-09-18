require 'test_helper'

class BouncedMailAddressTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  def setup
    @bounced_mail = BouncedMailAddress.new
    @bounced_mail.email = 'recipient@registry.test'
    @bounced_mail.bounce_reason = 'failed (5.1.1 smtp; 550 5.1.1 user unknown)'
    @bounced_mail.response_json = {"mail"=>{"source"=>"noreply@internet.test", "sourceIp"=>"195.43.86.5", "messageId"=>"010f0174a0c7d348-ea6e2fc1-0854-4073-b71f-5cecf9b0d0b2-000000", "sourceArn"=>"arn:aws:ses:us-east-2:650268220328:identity/noreply@internet.test", "timestamp"=>"2020-09-18T10:34:44.000Z", "destination"=>["#{@bounced_mail.email}"], "sendingAccountId"=>"650268220328"}, "bounce"=>{"timestamp"=>"2020-09-18T10:34:44.911Z", "bounceType"=>"Permanent", "feedbackId"=>"010f0174a0c7d4f9-27d59756-6111-xxxx-a507-26bee0d55fa2-000000", "remoteMtaIp"=>"127.0.0.1", "reportingMTA"=>"dsn; xxx.amazonses.com", "bounceSubType"=>"General", "bouncedRecipients"=>[{"action"=>"failed", "status"=>"5.1.1", "emailAddress"=>"#{@bounced_mail.email}", "diagnosticCode"=>"smtp; 550 5.1.1 user unknown"}]}, "notificationType"=>"Bounce"}
    @bounced_mail.recipient_json = {"action"=>"failed", "status"=>"5.1.1", "emailAddress"=>"#{@bounced_mail.email}", "diagnosticCode"=>"smtp; 550 5.1.1 user unknown"}

  end

  def test_bounce_reason_is_autoassigned
    assert @bounced_mail.valid?
    @bounced_mail.bounce_reason = nil
    assert @bounced_mail.valid?

    assert_equal 'failed (5.1.1 smtp; 550 5.1.1 user unknown)', @bounced_mail.bounce_reason
  end

  def test_response_json_is_required
    assert @bounced_mail.valid?
    @bounced_mail.response_json = nil
    assert_not @bounced_mail.valid?
    assert @bounced_mail.errors.full_messages.include? 'Response json is missing'
  end

  def test_recipient_json_is_required
    assert @bounced_mail.valid?
    @bounced_mail.recipient_json = nil
    assert_not @bounced_mail.valid?

    assert @bounced_mail.errors.full_messages.include? 'Recipient json is missing'
  end

  def test_status_is_determined_dynamically
    assert @bounced_mail.valid?
    assert_equal '5.1.1', @bounced_mail.status
    @bounced_mail.recipient_json['status'] = 'xxx_status'
    assert_equal 'xxx_status', @bounced_mail.status
  end

  def test_action_is_determined_dynamically
    assert @bounced_mail.valid?
    assert_equal 'failed', @bounced_mail.action
    @bounced_mail.recipient_json['action'] = 'xxx_action'
    assert_equal 'xxx_action', @bounced_mail.action
  end

  def test_diagnostic_is_determined_dynamically
    assert @bounced_mail.valid?
    assert_equal 'smtp; 550 5.1.1 user unknown', @bounced_mail.diagnostic
    @bounced_mail.recipient_json['diagnosticCode'] = 'xxx_diagnostic'
    assert_equal 'xxx_diagnostic', @bounced_mail.diagnostic
  end

  def test_creates_objects_from_sns_json
  end
end
