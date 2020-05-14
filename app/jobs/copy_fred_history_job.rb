class CopyFredHistoryJob < Que::Job
  include FredSqlUtils

  def run
    binding.pry
  end

  def domain_history(legacy_id)
    sql = <<~SQL.gsub(/\s+/, " ").strip
      select ena.status, oh.*, ae.*, obr.*, eos1.name as from_name, eos2.name as to_name
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
    binding = { id: legacy_id }
    result_entries(sql: sql, bind: binding)
  end

  def domain_with_registrant(legacy_id)
    sql = <<~SQL.gsub(/\s+/, " ").strip
      select dh.*, o.name as domain_name, c.*
      from domain_history dh
      join object_registry o on dh.id = o.id
      join contact c on dh.registrant = c.id
      where o.id=:id
      order by domain_name ASC
    SQL
    binding = { id: legacy_id }
    result_entries(sql: sql, bind: binding)
  end

  def contact_history
    sql = <<~SQL.gsub(/\s+/, " ").strip
      select * from contact_history
    SQL
    result_entries(sql)
  end
end

