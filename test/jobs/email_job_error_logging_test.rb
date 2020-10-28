require "test_helper"

class EmailJobLoggingTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  setup do
    ActionMailer::Base.deliveries.clear
  end

  def test_runs_saving_method
    domain = domains(:shop)

    perform_enqueued_jobs do
      StubEmailJob.perform_now domain.id
    end
  end
end

class StubEmailJob < EmailJob
  queue_as :default

  def perform(domain_id)
    domain = Domain.find(domain_id)
    @email =  domain.registrant.email

    raise StandardError
  end
end
