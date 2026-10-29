require 'test_helper'

class AdminPendingOperationAuditTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include ActiveJob::TestHelper

  def setup
    super
    @admin = users(:admin)
    sign_in @admin
    @domain = domains(:hospital)
    @token = 'admin-pending-token'
    @id = PendingOperationEvent.operation_id(@token)
    @domain.update!(statuses: [DomainStatus::PENDING_DELETE_CONFIRMATION],
                    registrant_verification_token: @token, registrant_verification_asked_at: Time.current)
  end

  %w[approved denied].each do |outcome|
    define_method("test_admin_#{outcome}_has_admin_actor") do
      perform_enqueued_jobs do
        if outcome == 'approved'
          patch admin_domain_pending_delete_path(@domain, 1)
        else
          delete admin_domain_pending_delete_path(@domain, 1)
        end
      end
      event = PendingOperationEvent.find_by!(pending_operation_id: @id, event: outcome)
      assert_equal 'admin', event.actor_type
      assert_equal @admin.id.to_s, event.actor_id
      assert_equal @admin.username, event.actor_name
    end
  end

  test 'admin can approve a pending deletion after 48 hours' do
    @domain.update_columns(registrant_verification_asked_at: 49.hours.ago)
    perform_enqueued_jobs { patch admin_domain_pending_delete_path(@domain, 1) }
    event = PendingOperationEvent.find_by!(pending_operation_id: @id, event: 'approved')
    assert_equal 'admin', event.actor_type
    assert_equal @admin.id.to_s, event.actor_id
    assert_includes @domain.reload.statuses, DomainStatus::PENDING_DELETE
  end

  test 'manual status removal records admin cancellation' do
    patch admin_domain_path(@domain), params: { domain: { statuses: [DomainStatus::OK] } }
    event = PendingOperationEvent.find_by!(pending_operation_id: @id, event: 'cancelled')
    assert_equal 'admin', event.actor_type
    assert_equal @admin.id.to_s, event.actor_id
  end
end
