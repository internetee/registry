require 'test_helper'

class OutzoneInvalidEmailDomainsJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  setup do
    ActionMailer::Base.deliveries.clear
    @domain = domains(:airport)
  end

  def test_set_outzone_datetime_for_fd_domains_by_invalid_emails
    @domain.update(valid_to: Time.zone.now + 3.years)
    @domain.reload

    assert_nil @domain.outzone_at

    @domain.schedule_force_delete(type: :soft)
    @domain.force_delete_data = {"template_name"=>"invalid_email", "force_delete_type"=>"soft"}
    @domain.save

    OutzoneInvalidEmailDomainsJob.perform_now
    @domain.reload

    assert @domain.force_delete_scheduled?
    assert @domain.valid_to > Time.zone.now + 1.year
    assert_equal @domain.outzone_at, @domain.force_delete_start + Setting.expire_warning_period.day
  end
end
