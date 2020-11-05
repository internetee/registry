class MassAction
  def self.process(action_type, entries)
    return false unless %w[force_delete].include?(action_type)

    entries = CSV.read(entries, headers: true)
    process_force_delete(entries) if action_type == force_delete
  rescue StandardError
    false
  end

  def self.process_force_delete(entries)
    return false unless force_delete_entries_valid?(entries)

    apply_force_deletes(entries)
  end

  def self.apply_force_deletes(entries)
    log = { ok: [], fail: [] }
    entries.each do |e|
      dn = Domain.find_by(name_puny: e['domain_name'])
      log[:fail] << e['domain_name'] and next unless dn

      dn.schedule_force_delete(type: :soft, reason: e['delete_reason'])
      log[:ok] << dn.name
    end

    log
  end

  def self.force_delete_entries_valid?(entries)
    entries.each do |e|
      reasons = %w[ENTITY_BURIED EMAIL PHONE]
      return false unless e['domain_name'].present? && reasons.include?(e['delete_reason'])
    end

    true
  end
end
