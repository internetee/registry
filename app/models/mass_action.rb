class MassAction
  def self.process(action_type, entries)
    entries = CSV.read(entries, headers: true)
    case action_type
    when 'force_delete'
      return false unless force_delete_entries_valid?(entries)

      process_force_delete(entries)
    end
  rescue StandardError
    false
  end

  def self.process_force_delete(entries)
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
    valid = true
    entries.each do |e|
      unless e['domain_name'].present? && %w[IDENT_BURIED EMAIL PHONE].include?(e['delete_reason'])
        valid = false
      end
    end

    valid
  rescue StandardError
    false
  end
end
