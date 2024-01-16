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
    email = '~@internet.ee'

    contact = @domain.admin_contacts.first
    contact.update_attribute(:email, email)
    (ValidationEvent::VALID_EVENTS_COUNT_THRESHOLD).times do
      contact.verify_email
    end
    contact.reload

    refute contact.validation_events.last.success?
    assert contact.need_to_start_force_delete?
  end



  # def test_fd_didnt_set_if_mx_interation_less_then_value
  #   @domain.update(valid_to: Time.zone.parse('2012-08-05'))
  #   assert_not @domain.force_delete_scheduled?
  #   travel_to Time.zone.parse('2010-07-05')

  #   email = 'email@somestrangedomain12345.ee'
  #   contact = @domain.admin_contacts.first
  #   contact.update_attribute(:email, email)
  #   (ValidationEvent::VALID_EVENTS_COUNT_THRESHOLD - 4).times do
  #     contact.verify_email(check_level: 'mx')
  #   end
  #   contact.reload

  #   refute contact.validation_events.limit(ValidationEvent::VALID_EVENTS_COUNT_THRESHOLD)
  #                 .any?(&:success?)
  #   assert_not contact.need_to_start_force_delete?
  # end

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

  def test_if_fd_need_to_be_set_if_invalid_smtp
    @domain.update(valid_to: Time.zone.parse('2012-08-05'))
    assert_not @domain.force_delete_scheduled?
    travel_to Time.zone.parse('2010-07-05')

    email = 'email@somestrangedomain12345.ee'
    contact = @domain.admin_contacts.first
    contact.update_attribute(:email, email)
    contact.verify_email(check_level: 'smtp')

    contact.reload

    refute contact.validation_events.limit(ValidationEvent::VALID_EVENTS_COUNT_THRESHOLD)
                  .any?(&:success?)
    assert contact.need_to_start_force_delete?
  end
end
