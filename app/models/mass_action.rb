class MassAction
  def self.process(action_type, entries)
    return process_force_delete(entries) if action_type == 'force_delete'

    false
  end

  def self.process_force_delete(entries)
    log = { ok: [], fail: [] }
    entries = CSV.read(entries, headers: true)
    entries.each do |e|
      dn = Domain.find_by(name_puny: e['Domain name'])
      log[:fail] << e['Domain name'] and next unless dn

      dn.schedule_force_delete(type: :soft, notify: true)
      log[:ok] << dn.name
    end

    log
  end
end
