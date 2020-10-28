require "test_helper"

class EmailJobLoggingTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  setup do
    ActionMailer::Base.deliveries.clear
  end

  def test_runs_saving_method
    domain = domains(:shop)
    error = 'StandardError'

    assert_difference -> { BouncedMailAddress.all.count }, 1 do
      perform_enqueued_jobs do
        StubEmailJob.perform_now(domain.id, error)
      end
    end

    bounced_mail_address = BouncedMailAddress.last
    assert_equal bounced_mail_address.email, domain.registrant.email
    assert_equal bounced_mail_address.job_name, 'StubEmailJob'
    assert_equal bounced_mail_address.error_description, error
  end
end

class StubEmailJob < EmailJob
  queue_as :default

  def perform(domain_id, error)
    domain = Domain.find(domain_id)
    @email =  domain.registrant.email

    raise error.constantize
  end
end
