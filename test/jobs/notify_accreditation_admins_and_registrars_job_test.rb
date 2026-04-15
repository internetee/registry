require 'test_helper'

class NotifyAccreditationAdminsAndRegistrarsJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  setup do
    ActionMailer::Base.deliveries.clear
  end

  def test_inform_registrars_if_accredation_date_is_expires
    registrar = registrars(:bestnames)
    registrar.accreditation_date = Time.current - 2.years - 1.day
    registrar.accreditation_expire_date = Time.current - 1.day
    registrar.save
    registrar.reload

    perform_enqueued_jobs do
      NotifyAccreditationAdminsAndRegistrarsJob.perform_now
    end

    assert_emails 1
  end

  def test_inform_registrars_if_deadline_date_in_one_month
    travel_to Time.zone.parse('2026-01-15 12:00:00') do
      registrar = registrars(:bestnames)
      registrar.accreditation_date = Time.current - 2.years
      registrar.accreditation_expire_date = Time.current + 1.month
      registrar.save
      registrar.reload

      perform_enqueued_jobs do
        NotifyAccreditationAdminsAndRegistrarsJob.perform_now
      end

      assert_emails 1
    end
  end
end
