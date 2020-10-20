$VERBOSE=nil
require 'test_helper'

class ActiveJobQueuingTest < ActiveJob::TestCase

  setup do
    ActiveJob::Base.queue_adapter = :test
  end

  def test_job_discarded_after_error
    assert_no_enqueued_jobs
    assert_performed_jobs 1 do
      TestDiscardedJob.perform_later
    end
    assert_no_enqueued_jobs
  end

  def test_job_retried_after_error
    assert_no_enqueued_jobs
    assert_raises StandardError do
      assert_performed_jobs 3 do
        TestRetriedJob.perform_later
      end
    end

    assert_no_enqueued_jobs
  end

end

class TestDiscardedJob < ApplicationJob
  queue_as :default

  discard_on StandardError

  def perform
    raise StandardError
  end
end

class TestRetriedJob < ApplicationJob
  queue_as :default

  retry_on StandardError, wait: 2.seconds, attempts: 3

  def perform
    raise StandardError
  end
end
