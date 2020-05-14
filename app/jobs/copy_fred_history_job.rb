class CopyFredHistoryJob < Que::Job
  include FredSqlUtils

  def run
    process_domains
    process_contacts
  end

  def process_domain(domain)
    new_history_array = []
    history_entries = object_history(domain.legacy_id)
    history_entries.each do |entry|
      recorded_at = entry[:update]
      attrs = { recorded_at: recorded_at, object_id: domain.id }

      already_exist = Audit::DomainHistory.find_by(attrs).present?
      next if already_exist

      attrs[:old_value] = { statuses: [process_status(entry[:from_status])] }
      attrs[:new_value] = { statuses: [process_status(entry[:to_status])],
                            name: entry[:name] }
      attrs[:action] = process_action(entry[:status])
      new_history_array << attrs
    end

    Audit::DomainHistory.transaction { Audit::DomainHistory.import new_history_array }
  end

  def process_domains
    Domain.without_ignored_columns do
      fred_history_domains = Domain.where.not(legacy_id: nil)
      fred_history_domains.find_each do |domain|
        process_domain(domain)
      end
    end
  end

  def process_contacts

  end

  def process_status(status)
    status.blank? ? 'ok' : status
  end

  def process_action(action)
    case action
    when 'DomainUpdate', 'DomainRenew', 'DomainTransfer'
      'UPDATE'
    when `DomainCreate`
      'INSERT'
    else
      'DELETE'
    end
  end

  def object_history(legacy_id)
    sql = <<~SQL.gsub(/\s+/, " ").strip
      select ena.status, oh.*, ae.*, obr.*, eos1.name as from_status, eos2.name as to_status
      from object_history oh
      join history h on h.id = oh.historyid
      join action a on a.id = h.action
      join action_elements ae on a.id = ae.actionid
      join object_registry obr on obr.id = oh.id
      left join object_state obs1 on obs1.ohid_from = h.id
      left join object_state obs2 on obs2.ohid_to = h.id
      left join enum_object_states eos1 on obs1.state_id = eos1.id
      left join enum_object_states eos2 on obs2.state_id = eos2.id
      join enum_action ena on ena.id = a.action
      where obr.type = 3
      AND obr.id=:id
      order by obr.name ASC, crdate ASC
    SQL
    bind = { id: legacy_id }
    result_entries(sql: sql, bind: bind)
  end

  def domain_with_registrant_history(legacy_id)
    sql = <<~SQL.gsub(/\s+/, " ").strip
      select dh.*, o.name as domain_name, c.*
      from domain_history dh
      join object_registry o on dh.id = o.id
      join contact c on dh.registrant = c.id
      where o.id=:id
      order by domain_name ASC
    SQL
    bind = { id: legacy_id }
    result_entries(sql: sql, bind: bind)
  end

  def contact_history
    sql = <<~SQL.gsub(/\s+/, " ").strip
      select * from contact_history
    SQL
    result_entries(sql)
  end
end

