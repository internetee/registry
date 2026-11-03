require 'test_helper'

class PendingOperationEventTest < ActiveSupport::TestCase
  test 'records identity once and enforces a single terminal event' do
    domain = domains(:hospital)
    domain.registrant_verification_token = 'secret-token'
    actor = { type: 'registrant', id: 42, name: 'Person', identity: { registrant_ident: 'EE-123' }, authenticated_at: Time.current.change(usec: 0) }
    2.times { PendingOperationEvent.record_authenticated(domain: domain, actor: actor) }
    id = PendingOperationEvent.operation_id(domain.registrant_verification_token)
    assert_equal 1, PendingOperationEvent.where(pending_operation_id: id, event: 'authenticated').count
    event = PendingOperationEvent.find_by!(pending_operation_id: id, event: 'authenticated')
    assert_equal 'EE-123', event.identity['registrant_ident']
    assert_equal actor[:authenticated_at], event.authenticated_at
    PendingOperationEvent.record(domain: domain, event: 'approved', actor: actor)
    PendingOperationEvent.record(domain: domain, event: 'denied', actor: actor)
    assert_equal ['approved'], PendingOperationEvent.where(pending_operation_id: id, event: %w[approved denied]).pluck(:event)
  end
  test 'audit storage failure does not raise' do
    domain = domains(:hospital)
    domain.registrant_verification_token = 'audit-error-token'
    PendingOperationEvent.stub(:create!, ->(*) { raise 'audit unavailable' }) do
      assert_nil PendingOperationEvent.record(domain: domain, event: 'started', actor: { type: 'system' })
    end
  end

end
