require 'test_helper'

class PendingOperationLifecycleTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  def setup
    super
    @domain = Domain.find(domains(:shop).id)
    @registrar = @domain.registrar
  end

  test 'delete start and delivered request record registrar and recipient' do
    @domain.registrant_verification_asked!({}, @registrar.id)
    operation_id = PendingOperationEvent.operation_id(@domain.registrant_verification_token)
    perform_enqueued_jobs { @domain.pending_delete! }
    started = PendingOperationEvent.find_by!(pending_operation_id: operation_id, event: 'started')
    assert_equal @registrar.id.to_s, started.actor_id
    assert_equal @registrar.name, started.actor_name
    email = PendingOperationEvent.find_by!(pending_operation_id: operation_id, event: 'email_sent')
    assert_equal @domain.registrant.email, email.recipient_email
    assert_equal 'system', email.actor_type
  end

  test 'change start and delivered request record registrar and recipient' do
    new_registrant = Registrant.find(contacts(:william).id)
    @domain.registrant_verification_asked!({}, @registrar.id)
    @domain.registrant = new_registrant
    operation_id = PendingOperationEvent.operation_id(@domain.registrant_verification_token)
    @domain.save!
    perform_enqueued_jobs
    started = PendingOperationEvent.find_by!(pending_operation_id: operation_id, event: 'started')
    assert_equal @registrar.id.to_s, started.actor_id
    assert_equal @registrar.name, started.actor_name
    email = PendingOperationEvent.find_by!(pending_operation_id: operation_id, event: 'email_sent')
    assert_equal @domain.reload.registrant.email, email.recipient_email
  end

  test 'a stale job does nothing' do
    @domain.update!(statuses: [DomainStatus::PENDING_DELETE_CONFIRMATION], registrant_verification_token: 'new-token',
                    registrant_verification_asked_at: Time.current)
    old_id = PendingOperationEvent.operation_id('old-token')
    assert_no_difference ['PendingOperationEvent.count', '@domain.registrar.notifications.count'] do
      DomainDeleteConfirmJob.perform_now(@domain.id, RegistrantVerification::CONFIRMED, 'test', nil, old_id)
    end
    assert @domain.reload.pending_delete_confirmation?

  end

  test 'expiry records system outcome' do
    @domain.update!(statuses: [DomainStatus::PENDING_DELETE_CONFIRMATION], registrant_verification_token: 'expired-token',
                    registrant_verification_asked_at: 49.hours.ago)
    id = PendingOperationEvent.operation_id('expired-token')
    Domains::ExpiredPendings::ProcessClean.run!(domain: @domain)
    event = PendingOperationEvent.find_by!(pending_operation_id: id, event: 'expired')
    assert_equal 'system', event.actor_type
  end

  test 'force deletion keeps the operation open until domain destruction' do
    @domain.update!(statuses: [DomainStatus::PENDING_UPDATE], registrant_verification_token: 'force-token',
                    registrant_verification_asked_at: Time.current)
    id = PendingOperationEvent.operation_id('force-token')
    @domain.schedule_force_delete
    assert_not PendingOperationEvent.exists?(pending_operation_id: id, event: 'cancelled')
    assert_equal 'force-token', @domain.reload.registrant_verification_token
    @domain.destroy!
    event = PendingOperationEvent.find_by!(pending_operation_id: id, event: 'cancelled')
    assert_equal RegistrantVerification::DOMAIN_REGISTRANT_CHANGE, event.operation
    assert_equal 'system', event.actor_type
  end

  test 'lifting force deletion restores the operation for approval' do
    @domain.update!(statuses: [DomainStatus::PENDING_UPDATE], registrant_verification_token: 'restore-token',
                    registrant_verification_asked_at: Time.current)
    id = PendingOperationEvent.operation_id('restore-token')
    @domain.schedule_force_delete
    @domain.reload.cancel_force_delete
    assert @domain.reload.pending_update?
    assert_equal 'restore-token', @domain.registrant_verification_token
    assert_not PendingOperationEvent.exists?(pending_operation_id: id, event: 'cancelled')
    DomainUpdateConfirmJob.perform_now(@domain.id, RegistrantVerification::CONFIRMED, 'admin', nil, id)
    assert PendingOperationEvent.exists?(pending_operation_id: id, event: 'approved')
  end

  test 'delete rejection is audited even if sending the mail fails' do
    @domain.update!(statuses: [DomainStatus::PENDING_DELETE_CONFIRMATION], registrant_verification_token: 'smtp-token',
                    registrant_verification_asked_at: Time.current)
    id = PendingOperationEvent.operation_id('smtp-token')
    DomainDeleteMailer.stub(:rejected, ->(*) { raise 'SMTP unavailable' }) do
      assert_raises(RuntimeError) do
        Domains::DeleteConfirm::ProcessDeleteRejected.run!(domain: @domain, action: RegistrantVerification::REJECTED)
      end
    end
    assert PendingOperationEvent.exists?(pending_operation_id: id, event: 'denied')
    assert_not @domain.reload.pending_delete_confirmation?
  end

  test 'verified delete terminates an existing delete confirmation' do
    @domain.update!(statuses: [DomainStatus::PENDING_DELETE_CONFIRMATION], registrant_verification_token: 'delete-token',
                    registrant_verification_asked_at: Time.current)
    domain = Epp::Domain.find(@domain.id)
    id = PendingOperationEvent.operation_id('delete-token')
    assert domain.set_pending_delete!
    event = PendingOperationEvent.find_by!(pending_operation_id: id, event: 'cancelled')
    assert_equal 'registrar', event.actor_type
    assert_equal @registrar.id.to_s, event.actor_id
    assert_not domain.reload.registrant_delete_confirmable?('delete-token')
  end

  test 'unlock records the actor if restoring statuses removes a pending operation' do
    assert @domain.apply_registry_lock(extensions_prohibited: false)
    @domain.update_columns(statuses: @domain.statuses + [DomainStatus::PENDING_UPDATE],
                           registrant_verification_token: 'locked-token', registrant_verification_asked_at: Time.current)
    @domain.reload
    id = PendingOperationEvent.operation_id('locked-token')
    admin = users(:admin)
    assert @domain.remove_registry_lock(actor: { type: 'admin', id: admin.id, name: admin.username })
    event = PendingOperationEvent.find_by!(pending_operation_id: id, event: 'cancelled')
    assert_equal 'admin', event.actor_type
    assert_equal admin.id.to_s, event.actor_id
  end

  test 'domain destruction retains cancellation event' do
    @domain.update!(statuses: [DomainStatus::PENDING_UPDATE], registrant_verification_token: 'destroy-token',
                    registrant_verification_asked_at: Time.current)
    id = PendingOperationEvent.operation_id('destroy-token')
    @domain.destroy!
    assert_equal 'system', PendingOperationEvent.find_by!(pending_operation_id: id, event: 'cancelled').actor_type
  end

end
