require 'test_helper'

class ValidationEventTest < ActiveSupport::TestCase

  setup do
    @domain = domains(:shop)
    Setting.redemption_grace_period = 30
    ActionMailer::Base.deliveries.clear
  end

  teardown do

  end

  def test_if_fd_need_to_be_set_if_invalid_email
    @domain.update(valid_to: Time.zone.parse('2012-08-05'))
    assert_not @domain.force_delete_scheduled?
    travel_to Time.zone.parse('2010-07-05')
    email = 'some@strangesentence@internet.ee'

    contact = @domain.admin_contacts.first
    contact.update_attribute(:email, email)
    contact.verify_email
    contact.reload

    refute contact.validation_events.last.success?
    assert contact.need_to_start_force_delete?
  end

  def test_if_fd_need_to_be_lifted_if_email_fixed
    test_if_fd_need_to_be_set_if_invalid_email

    email = 'email@internet.ee'

    contact = @domain.admin_contacts.first
    contact.update_attribute(:email, email)

    contact.verify_email
    contact.reload

    assert contact.need_to_lift_force_delete?
    assert contact.validation_events.last.success?
  end

  def test_if_fd_need_to_be_set_if_invalid_mx
    @domain.update(valid_to: Time.zone.parse('2012-08-05'))
    assert_not @domain.force_delete_scheduled?
    travel_to Time.zone.parse('2010-07-05')

    email = 'email@somestrangedomain12345.ee'
    contact = @domain.admin_contacts.first
    contact.update_attribute(:email, email)
    ValidationEvent::VALID_EVENTS_COUNT_THRESHOLD.times do
      contact.verify_email(check_level: 'mx')
    end
    contact.reload

    refute contact.validation_events.limit(ValidationEvent::VALID_EVENTS_COUNT_THRESHOLD)
                  .any?(&:success?)
    assert contact.need_to_start_force_delete?
  end

  def test_if_fd_need_to_be_lifted_if_mx_fixed
    test_if_fd_need_to_be_set_if_invalid_mx

    email = 'email@internet.ee'
    contact = @domain.admin_contacts.first
    contact.update_attribute(:email, email)
    contact.verify_email(check_level: 'mx')

    contact.reload
    assert contact.need_to_lift_force_delete?
    assert contact.validation_events.last.success?
  end

  def test_if_fd_need_to_be_set_if_invalid_smtp
    @domain.update(valid_to: Time.zone.parse('2012-08-05'))
    assert_not @domain.force_delete_scheduled?
    travel_to Time.zone.parse('2010-07-05')

    email = 'email@somestrangedomain12345.ee'
    contact = @domain.admin_contacts.first
    contact.update_attribute(:email, email)
    ValidationEvent::VALID_EVENTS_COUNT_THRESHOLD.times do
      contact.verify_email(check_level: 'smtp')
    end
    contact.reload

    refute contact.validation_events.limit(ValidationEvent::VALID_EVENTS_COUNT_THRESHOLD)
                  .any?(&:success?)
    assert contact.need_to_start_force_delete?
  end

  def test_if_fd_need_to_be_lifted_if_smtp_fixed
    test_if_fd_need_to_be_set_if_invalid_smtp

    email = 'valid@internet.ee'
    contact = @domain.admin_contacts.first
    contact.update_attribute(:email, email)
    contact.verify_email(check_level: 'smtp')

    contact.reload
    assert contact.need_to_lift_force_delete?
    assert contact.validation_events.last.success?
  end

end
