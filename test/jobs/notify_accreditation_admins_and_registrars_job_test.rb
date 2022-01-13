require 'test_helper'

class NotifyAccreditationAdminsAndRegistrarsJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  setup do
    ActionMailer::Base.deliveries.clear
  end

  def test_inform_registrars_if_accredation_date_is_expires
    api_user = users(:api_bestnames)
    api_user.accreditation_date = Time.now - 2.year - 1.day
    api_user.accreditation_expire_date = Time.now - 1.day
    api_user.save
    api_user.reload

      perform_enqueued_jobs do
        NotifyAccreditationAdminsAndRegistrarsJob.perform_now
      end

    assert_emails 1
  end

  # def test_inform_registrars_if_deadline_date_in_one_month
  #   api_user = users(:api_bestnames)
  #   api_user.accreditation_date = Time.now - 2.year - 1.day
  #   api_user.accreditation_expire_date = Time.now + 1.month - 1.day
  #   api_user.save
  #   api_user.reload
  #
  #   perform_enqueued_jobs do
  #     NotifyAccreditationAdminsAndRegistrarsJob.perform_now
  #   end
  #
  #   assert_emails 1
  # end

end
