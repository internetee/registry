class ReservedDomain::Audit < ActiveSupport::CurrentAttributes
  attribute :source, :reason, :reason_note, :registrar_id
end
