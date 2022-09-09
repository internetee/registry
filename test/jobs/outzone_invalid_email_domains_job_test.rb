require 'test_helper'

class OutzoneInvalidEmailDomainsJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  setup do
    ActionMailer::Base.deliveries.clear
    @domain = domains(:airport)
  end

  def test_set_outzone_datetime_for_fd_domains_by_invalid_emails
    assert_nil @domain.outzone_at

    @domain.schedule_force_delete(type: :soft)
    @domain.force_delete_data = {"template_name"=>"invalid_email", "force_delete_type"=>"soft"}
    @domain.save

    OutzoneInvalidEmailDomainsJob.perform_now
    @domain.reload

    assert @domain.force_delete_scheduled?
    assert @domain.valid_to < Time.zone.now + 1.year
    assert_equal @domain.outzone_at, @domain.force_delete_start + Setting.expire_warning_period.day
  end

  private

  def prepare_contact
    assert_not @domain.force_delete_scheduled?
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
end
