class CopyFredHistoryJob < Que::Job

  DATABASE = ActiveRecord::Base.configurations['fred_test']

  def run
    binding.pry
  end

  def domain_history
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
      order by obr.name ASC, crdate ASC
    SQL
    result_entries(sql)
  end

  def domain_with_registrant
    sql = <<~SQL.gsub(/\s+/, " ").strip
      select dh.*, o.name as domain_name, c.*
      from domain_history dh
      join object_registry o on dh.id = o.id
      join contact c on dh.registrant = c.id
      order by domain_name ASC
    SQL
    result_entries(sql)
  end

  def contact_history
    sql = <<~SQL.gsub(/\s+/, " ").strip
      select * from contact_history
    SQL
    result_entries(sql)
  end

  def with_another_db(another_db_config)
    original_connection = ActiveRecord::Base.remove_connection
    ActiveRecord::Base.establish_connection(another_db_config)
    yield
  ensure
    ActiveRecord::Base.establish_connection(original_connection)
  end

  def result_entries(sql)
    result = with_another_db(DATABASE) do
      ActiveRecord::Base.connection.exec_query(sql)
    end
    result.entries
  end

end

