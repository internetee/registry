require 'test_helper'

class EmailVerificationForceDeleteTest < ActiveJob::TestCase
  include ActiveJob::TestHelper

  setup do
    @domain = domains(:shop)
    @contact = contacts(:john)
    @old_validation_type = Truemail.configure.default_validation_type
    Truemail.configure.whitelisted_domains = ['email.com', 'internet2.ee']
    ValidationEvent.destroy_all
    ActionMailer::Base.deliveries.clear
  end

  teardown do
    Truemail.configure.default_validation_type = @old_validation_type
  end

  def test_email_update_does_not_cancel_force_delete_with_invalid_company_template
    @domain.update(valid_to: Time.zone.parse('2012-08-05'))
    travel_to Time.zone.parse('2010-07-05')

    @domain.schedule_force_delete(
      type: :soft,
      notify_by_email: true,
      reason: 'invalid_company',
      notes: "Company no: #{@domain.registrant.identifier.code}"
    )
    @domain.reload

    assert @domain.force_delete_scheduled?
    assert_equal 'invalid_company', @domain.template_name

    old_email = @contact.email
    new_valid_email = 'valid-email@email.com'
    @contact.update(email: new_valid_email, email_history: old_email)

    Truemail.configure.default_validation_type = :regex
    @contact.verify_email

    validation_event = @contact.validation_events.last
    assert validation_event.successful?
    assert @contact.need_to_lift_force_delete?

    @contact.remove_force_delete_for_valid_contact
    @domain.reload

    assert @domain.force_delete_scheduled?
    assert_equal 'invalid_company', @domain.template_name
    assert_includes @domain.statuses, DomainStatus::FORCE_DELETE
  end

  def test_email_update_cancels_force_delete_with_invalid_email_template
    @domain.update(valid_to: Time.zone.parse('2012-08-05'))
    travel_to Time.zone.parse('2010-07-05')

    @domain.schedule_force_delete(
      type: :soft,
      notify_by_email: true,
      reason: 'invalid_email',
      email: @contact.email
    )
    @domain.reload

    assert @domain.force_delete_scheduled?
    assert_equal 'invalid_email', @domain.template_name

    old_email = @domain.registrant.email
    new_valid_email = 'registrant@email.com'
    @domain.registrant.update(email: new_valid_email, email_history: old_email)
    @domain.registrant.verify_email
    assert @domain.registrant.need_to_lift_force_delete?

    @domain.contacts.each do |contact|
      contact.update(email: "valid-#{contact.code}@email.com", email_history: contact.email)
      contact.verify_email
      assert contact.need_to_lift_force_delete?
    end

    CheckForceDeleteLift.perform_now
    @domain.reload

    assert_not @domain.force_delete_scheduled?
    assert_not_includes @domain.statuses, DomainStatus::FORCE_DELETE
  end

  def test_cancel_force_delete_if_domain_attributes_are_valid_returns_early_for_invalid_company
    @domain.update(valid_to: Time.zone.parse('2012-08-05'))
    travel_to Time.zone.parse('2010-07-05')

    @domain.schedule_force_delete(
      type: :soft,
      notify_by_email: true,
      reason: 'invalid_company',
      notes: "Company no: #{@domain.registrant.identifier.code}"
    )
    @domain.reload

    assert_equal 'invalid_company', @domain.template_name

    @contact.stub :need_to_lift_force_delete?, true do
      @domain.registrant.stub :need_to_lift_force_delete?, true do
        result = @contact.cancel_force_delete_if_domain_attributes_are_valid?(@domain)

        assert_nil result
        assert @domain.force_delete_scheduled?
      end
    end
  end

  def test_cancel_force_delete_if_domain_attributes_are_valid_proceeds_for_invalid_email
    @domain.update(
      valid_to: Time.zone.parse('2012-08-05'),
      statuses: [DomainStatus::FORCE_DELETE, DomainStatus::SERVER_RENEW_PROHIBITED],
      force_delete_data: { 'template_name' => 'invalid_email', 'force_delete_type' => 'soft' },
      force_delete_start: Time.zone.parse('2010-08-05'),
      force_delete_date: Time.zone.parse('2010-09-19')
    )

    assert_equal 'invalid_email', @domain.template_name
    assert @domain.force_delete_scheduled?

    @contact.stub :need_to_lift_force_delete?, true do
      @domain.registrant.stub :need_to_lift_force_delete?, true do
        @contact.stub :is_domain_has_invalid_org_contact?, false do
          @contact.cancel_force_delete_if_domain_attributes_are_valid?(@domain)
          @domain.reload

          assert_not @domain.force_delete_scheduled?
        end
      end
    end
  end

  private

  def prepare_bounced_email_address(email)
    bounced_mail = BouncedMailAddress.new
    bounced_mail.email = email
    bounced_mail.message_id = '010f0174a0c7d348-ea6e2fc1-0854-4073-b71f-5cecf9b0d0b2-000000'
    bounced_mail.bounce_type = 'Permanent'
    bounced_mail.bounce_subtype = 'General'
    bounced_mail.action = 'failed'
    bounced_mail.status = '5.1.1'
    bounced_mail.diagnostic = 'smtp; 550 5.1.1 user unknown'
    bounced_mail.save!
  end
end