require 'test_helper'

module Domains
  class CancelPendingUpdateTest < ActiveSupport::TestCase
    include ActionMailer::TestHelper
    include ActiveJob::TestHelper

    setup do
      @domain = domains(:shop)
      @new_registrant = contacts(:william)
      @domain.update!(registrant_verification_asked_at: Time.zone.now,
                      registrant_verification_token: 'test')
      @domain.pending_json = { 'new_registrant_id' => @new_registrant.id,
                               'new_registrant_email' => @new_registrant.email,
                               'new_registrant_name' => @new_registrant.name }
      @domain.statuses = [DomainStatus::PENDING_UPDATE]
      @domain.save(validate: false)
      ActionMailer::Base.deliveries.clear
    end

    def test_clears_pending_update_data
      CancelPendingUpdate.run!(domain: @domain, initiator: 'test')
      @domain.reload

      assert_not_includes @domain.statuses, DomainStatus::PENDING_UPDATE
      assert_empty @domain.pending_json
      assert_nil @domain.registrant_verification_token
      assert_nil @domain.registrant_verification_asked_at
      assert_equal '', @domain.status_notes[DomainStatus::PENDING_UPDATE]
    end

    def test_keeps_registrant_untouched
      old_registrant = @domain.registrant

      CancelPendingUpdate.run!(domain: @domain, initiator: 'test')
      @domain.reload

      assert_equal old_registrant, @domain.registrant
    end

    def test_notifies_both_registrants
      registrant_email = @domain.registrant.email

      perform_enqueued_jobs do
        CancelPendingUpdate.run!(domain: @domain, initiator: 'test')
      end

      email = ActionMailer::Base.deliveries.last
      assert_includes email.to, @new_registrant.email
      assert_includes email.to, registrant_email
    end

    def test_updates_whois_record
      assert_enqueued_with(job: UpdateWhoisRecordJob, args: [@domain.name, 'domain']) do
        CancelPendingUpdate.run!(domain: @domain, initiator: 'test')
      end
    end

    def test_fails_when_domain_has_no_pending_update
      @domain.statuses = []
      @domain.save(validate: false)

      result = CancelPendingUpdate.run(domain: @domain, initiator: 'test')

      assert_not result.valid?
      assert_no_enqueued_emails
    end

    def test_does_not_touch_other_statuses
      @domain.statuses = [DomainStatus::PENDING_UPDATE, DomainStatus::CLIENT_HOLD]
      @domain.save(validate: false)

      CancelPendingUpdate.run!(domain: @domain, initiator: 'test')
      @domain.reload

      assert_includes @domain.statuses, DomainStatus::CLIENT_HOLD
      assert_not_includes @domain.statuses, DomainStatus::PENDING_UPDATE
    end
  end
end
