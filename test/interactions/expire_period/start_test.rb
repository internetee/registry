require 'test_helper'

class StartTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  setup do
    @domain = domains(:shop)
    @domain.update(expire_time: Time.zone.now - 1.day)
    ActionMailer::Base.deliveries.clear
  end

  def test_sets_expired
    job_count = lambda do
      QueJob.where("args->>0 = '#{@domain.id}'", job_class: DomainExpireEmailJob.name).count
    end

    assert_difference job_count, 1 do
      perform_enqueued_jobs do
        DomainCron.start_expire_period
      end
    end

    @domain.reload
    assert @domain.statuses.include?(DomainStatus::EXPIRED)
    assert_equal @domain.outzone_at, @domain.expire_time + Domain.expire_warning_period
    assert_equal @domain.delete_date, (@domain.outzone_at + Domain.redemption_grace_period).to_date
  end
end
