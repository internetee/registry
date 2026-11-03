class PendingOperationEvent < ApplicationRecord
  NAMESPACE = '0b47841d-c42b-5ccd-9221-3e6478d5304b'.freeze
  TERMINAL_EVENTS = %w[approved denied cancelled expired].freeze

  def self.operation_id(token)
    return if token.blank?

    Digest::UUID.uuid_v5(NAMESPACE, token)
  end

  def self.current_actor
    user = PaperTrail.request.whodunnit
    return { type: 'registrar', id: user.id, name: user.username } if user.is_a?(ApiUser)
    match = user.to_s.match(/\A(\d+)-(AdminUser|ApiUser): (.*)\z/)
    return { type: match[2] == 'AdminUser' ? 'admin' : 'registrar', id: match[1], name: match[3] } if match

    { type: 'system' }
  rescue StandardError
    { type: 'system' }
  end

  def self.record_authenticated(domain:, actor:)
    operation_id = self.operation_id(domain.registrant_verification_token)
    record(domain: domain, event: 'authenticated', actor: actor)
  rescue ActiveRecord::RecordNotUnique
    nil
  rescue StandardError => e
    Rails.logger.warn("Pending operation audit failed: #{e.class}: #{e.message}")
  end

  def self.record(domain:, event:, actor: {}, operation: nil, operation_id: nil, recipient_email: nil)
    operation_id ||= self.operation_id(domain.registrant_verification_token)
    return if operation_id.blank?

    actor = (actor || {}).with_indifferent_access
    operation ||= domain.pending_update? ? RegistrantVerification::DOMAIN_REGISTRANT_CHANGE : RegistrantVerification::DOMAIN_DELETE
    transaction(requires_new: true) do
      create!(pending_operation_id: operation_id, domain_id: domain.id, domain_name: domain.name,
              operation: operation, event: event, occurred_at: Time.current, actor_type: actor[:type],
              actor_id: actor[:id], actor_name: actor[:name], identity: actor[:identity],
              authenticated_at: actor[:authenticated_at], recipient_email: recipient_email)
    end
  rescue ActiveRecord::RecordNotUnique
    nil
  rescue StandardError => e
    Rails.logger.warn("Pending operation audit failed: #{e.class}: #{e.message}")
    nil
  end
end
