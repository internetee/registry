class CopyFredHistoryJob < Que::Job
  include FredSqlUtils
  attr_accessor :initial_contacts_history, :object_history, :domain_contacts

  def run
    process_domains
    # process_contacts
  end

  def process_domain(domain)
    new_history_array = []
    history_entries = object_history.select { |entry| entry[:id] == domain.legacy_id }
    history_entries.each do |entry|
      recorded_at = entry[:update]
      attrs = { recorded_at: recorded_at, object_id: domain.id }

      already_exist = Audit::DomainHistory.find_by(attrs).present?
      next if already_exist

      start_reg = initial_contacts_history.detect{ |val| val[:id] == entry[:registrant] }
      admin_contact_id = domain_contacts.detect{ |val| val[:domainid] == entry[:id] }[:contactid]
      admin = initial_contacts_history.detect{ |val| val[:id] == admin_contact_id }

      attrs[:old_value] = { statuses: process_status(entry[:from_status]) }
      attrs[:new_value] = { statuses: process_status(entry[:to_status]),
                            name: entry[:name],
                            children: { registrant: [entry[:registrant]],
                                        admin_contact: [admin_contact_id],
                                        registrant_initial: { id: entry[:registrant],
                                                              fax: start_reg[:fax],
                                                              zip: start_reg[:postalcode],
                                                              city: start_reg[:city],
                                                              name: start_reg[:name],
                                                              email: start_reg[:email],
                                                              ident: start_reg[:ssn],
                                                              phone: start_reg[:telephone],
                                                              state: start_reg[:stateorprovince],
                                                              street: start_reg[:street1] },
                                        admin_contacts_initial: [{ id: admin[:id],
                                                                   fax: admin[:fax],
                                                                   zip: admin[:postalcode],
                                                                   city: admin[:city],
                                                                   name: admin[:name],
                                                                   email: admin[:email],
                                                                   ident: admin[:ssn],
                                                                   phone: admin[:telephone],
                                                                   state: admin[:stateorprovince],
                                                                   street: admin[:street1] }] } }
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
    status = status.gsub(/{|}|NULL/, '').split(',')
    status.blank? ? ['ok'] : status
  end

  def process_action(action)
    case action
    when 'DomainUpdate', 'DomainRenew', 'DomainTransfer'
      'UPDATE'
    when 'DomainCreate'
      'INSERT'
    else
      'DELETE'
    end
  end

  def object_history
    @object_history ||= object_request
  end

  def object_request
    sql = <<~SQL.gsub(/\s+/, " ").strip
      select ena.status, oh.id, h.valid_from as update, oh.historyid, obr.name, d.registrant,
             array_agg(eos1.name) as from_status,  array_agg(eos2.name) as to_status
      from object_history oh
      join history h on h.id = oh.historyid
      join action a on a.id = h.action
      join action_elements ae on a.id = ae.actionid
      join object_registry obr on obr.id = oh.id
      join domain d on obr.id = d.id
      left join object_state obs1 on h.id = obs1.ohid_from
      left join object_state obs2 on h.id = obs2.ohid_to
      left join enum_object_states eos1 on obs1.state_id = eos1.id
      left join enum_object_states eos2 on obs2.state_id = eos2.id
      join enum_action ena on ena.id = a.action
      where obr.type = 3
      group by oh.historyid, ena.status, h.valid_from, oh.id, obr.name, crdate, d.registrant
      order by obr.name ASC, crdate ASC
    SQL
    result_entries(sql: sql)
  end

  def domain_contacts
    @domain_contacts ||= domain_contact_request
  end

  def domain_contact_request
    sql = <<~SQL.gsub(/\s+/, " ").strip
      SELECT DISTINCT ON (domainid)
                          domainid, contactid
      FROM   domain_contact_map_history
      ORDER  BY domainid, historyid;
    SQL
    result_entries(sql: sql)
  end

  def initial_contacts_history
    @initial_contacts_history ||= initial_contacts_request
  end

  def initial_contacts_request
    sql = <<~SQL.gsub(/\s+/, " ").strip
            WITH summary AS (
              SELECT ch.id,
                     ch.name,
                     ch.historyid,
                     ROW_NUMBER() OVER(PARTITION BY ch.id
                                           ORDER BY ch.historyid asc) AS rk
                FROM contact_history ch)
      SELECT s.*, ch.*
        FROM summary s
        join contact_history ch on s.historyid = ch.historyid
       WHERE s.rk = 1
    SQL
    result_entries(sql: sql)
  end
end

