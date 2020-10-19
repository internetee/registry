require 'test_helper'

class RegistrantChangeExpiredEmailJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  setup do
    ActionMailer::Base.deliveries.clear
  end

  def test_delivers_email
    domain = domains(:shop)
    domain.update!(pending_json: {new_registrant_email: 'aaa@bbb.com'})
    domain_id = domain.id

    assert_performed_jobs 1 do
      perform_enqueued_jobs do
        RegistrantChangeExpiredEmailJob.perform_later(domain_id)
      end
    end

    assert_emails 1
  end

end
