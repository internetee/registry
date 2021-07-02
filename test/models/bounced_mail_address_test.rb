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

    @contact_email = "john@inbox.test"
  end

  def test_remove_bounced_email_after_changed_related_email
    @bounced_mail.update(email: @contact_email)
    @bounced_mail.save

    contacts_with_bounced_mails = Contact.where(email: @contact_email)
    contacts_with_bounced_mails.each do |contact|
      contact.email = "sara@inbox.com"
      contact.save
    end

    BouncedEmailsCleanerJob.perform_now

    assert_nil BouncedMailAddress.find_by(email: @contact_email)
  end

  def test_soft_force_delete_related_domains
    domain_contacts = Contact.where(email: @contact_email).map(&:domain_contacts).flatten

    domain_contacts.each do |domain_contact|
      domain_contact.domain.update(valid_to: Time.zone.now + 5.years)
      assert_not domain_contact.domain.statuses.include? DomainStatus::FORCE_DELETE
      assert_not domain_contact.domain.statuses.include? DomainStatus::SERVER_RENEW_PROHIBITED
      assert_not domain_contact.domain.statuses.include? DomainStatus::SERVER_TRANSFER_PROHIBITED
    end

    @bounced_mail.email = @contact_email
    @bounced_mail.save

    domain_contacts.each do |domain_contact|
      domain_contact.reload
      assert_equal 'soft', domain_contact.domain.force_delete_type
      assert domain_contact.domain.force_delete_scheduled?
      assert domain_contact.domain.statuses.include? DomainStatus::FORCE_DELETE
      assert domain_contact.domain.statuses.include? DomainStatus::SERVER_RENEW_PROHIBITED
      assert domain_contact.domain.statuses.include? DomainStatus::SERVER_TRANSFER_PROHIBITED
    end
  end

  def test_soft_force_delete_if_domain_has_force_delete_status
    domain_contacts = Contact.where(email: @contact_email).map(&:domain_contacts).flatten
    perform_enqueued_jobs do
      domain_contacts.each do |domain_contact|
        domain_contact.domain.update(valid_to: Time.zone.now + 5.years)
        domain_contact.domain.schedule_force_delete(type: :soft, notify_by_email: false, reason: 'test')
      end
    end
    force_delete_date = domain_contacts.map(&:domain).each.pluck(:force_delete_date).sample
    assert_not_nil force_delete_date

    @bounced_mail.email = @contact_email
    @bounced_mail.save

    domain_contacts.all? do |domain_contact|
      assert_equal force_delete_date, domain_contact.domain.force_delete_date
      assert_equal 'soft', domain_contact.domain.force_delete_type
      assert domain_contact.domain.force_delete_scheduled?
    end
  end

  def test_email_is_required
    assert @bounced_mail.valid?
    @bounced_mail.email = nil
    assert @bounced_mail.invalid?
  end

  def test_message_id_is_required
    assert @bounced_mail.valid?
    @bounced_mail.message_id = nil
    assert @bounced_mail.invalid?
  end

  def test_bounce_type_is_required
    assert @bounced_mail.valid?
    @bounced_mail.bounce_type = nil
    assert @bounced_mail.invalid?
  end

  def test_bounce_subtype_is_required
    assert @bounced_mail.valid?
    @bounced_mail.bounce_subtype = nil
    assert @bounced_mail.invalid?
  end

  def test_action_is_required
    assert @bounced_mail.valid?
    @bounced_mail.action = nil
    assert @bounced_mail.invalid?
  end

  def test_status_is_required
    assert @bounced_mail.valid?
    @bounced_mail.status = nil
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

  def test_email_with_bounce_considered_nonverified
    BouncedMailAddress.record(sns_bounce_payload)
    bounced_mail = BouncedMailAddress.last
    registrant = domains(:shop).registrant

    assert_equal registrant.email, bounced_mail.email
    assert registrant.email_verification_failed?
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
