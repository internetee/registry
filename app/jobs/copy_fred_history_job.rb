class CopyFredHistoryJob < Que::Job
  include FredSqlUtils
  attr_accessor :initial_contacts_history, :object_history, :domain_contacts, :contacts_history,
                :legacy_domain_data, :legacy_contact_data

  def run(prepare: false)
    Rails.logger = Logger.new(STDOUT)
    prepare_staging if prepare
    process_domains unless prepare
    process_contacts unless prepare
  end

  def prepare_staging
    logger.info 'Starting preparing staging domain data'
    Domain.without_ignored_columns do
      Domain.find_each do |domain|
        logger.info "Check if there is FRED entry for the #{domain.name}"
        entry = legacy_domain_data.detect { |entry| entry[:name] == domain.name }
        domain.update_columns(legacy_id: entry[:id]) if entry && domain.legacy_id != entry[:id]
      end
    end
    logger.info 'Finished preparing staging domain data'
    logger.info 'Starting preparing staging contact data'
    Contact.without_ignored_columns do
      Contact.find_each do |contact|
        logger.info "Check if there is FRED entry for the #{contact.name}"
        entry = legacy_contact_data.detect { |entry| entry[:name] == contact.name }
        contact.update_columns(legacy_id: entry[:id]) if entry && contact.legacy_id != entry[:id]
      end
    end
    logger.info 'Finished preparing staging contact data'
  end

  def logger
    Rails.logger
  end

  def process_domain(domain)
    logger.info "Starting processing domain #{domain.name}"
    new_history_array = []
    history_entries = object_history.select { |entry| entry[:id] == domain.legacy_id }
    return if history_entries.empty?

    history_entries.each do |entry|
      recorded_at = entry[:update].to_datetime
      attrs = { recorded_at: recorded_at, object_id: domain.id }

      already_exist = Audit::DomainHistory.find_by(attrs).present?
      next if already_exist
      logger.info "FRED history of #{domain.name} didn't imported yet, proceeding"

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
    logger.info "Finished processing domain #{domain.name}"
  end

  def process_domains
    Domain.without_ignored_columns do
      fred_history_domains = Domain.where.not(legacy_id: nil)
      fred_history_domains.find_each do |domain|
        process_domain(domain)
      end
    end
  end

  def process_contact(contact)
    logger.info "Starting processing contact #{contact.id}/#{contact.name}"
    new_history_array = []
    history_entries = contacts_history.select { |entry| entry[:id] == contact.legacy_id }
    return if history_entries.empty?

    history_entries.each do |entry|
      recorded_at = entry[:update].to_datetime
      attrs = { recorded_at: recorded_at, object_id: contact.id }
      already_exist = Audit::ContactHistory.find_by(attrs).present?
      next if already_exist

      logger.info "FRED history of contact #{contact.id}/#{contact.name} didn't imported yet."

      attrs[:action] = 'UPDATE'
      attrs[:old_value] = {}
      attrs[:new_value] = {
          id: contact.id,
          fax: entry[:fax],
          zip: entry[:postalcode],
          city: entry[:city],
          name: entry[:name],
          email: entry[:email],
          ident: entry[:ssn],
          phone: entry[:telephone],
          state: entry[:stateorprovince],
          street: entry[:street1],
          legacy_id: entry[:id],
          country_code: entry[:country],
          ident_country_code: entry[:country]
      }
      new_history_array << attrs
    end

    Audit::ContactHistory.transaction { Audit::ContactHistory.import new_history_array }
    logger.info "Finished processing contact #{contact.id}/#{contact.name}"
  end

  def process_contacts

    Contact.without_ignored_columns do
      fred_history_contacts = Contact.where.not(legacy_id: nil)
      fred_history_contacts.find_each do |contact|
        process_contact(contact)
      end
    end
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

  def contacts_history
    @contacts_history ||= contacts_history_request
  end

  def contacts_history_request
    sql = <<~SQL.gsub(/\s+/, " ").strip
      select ch.*, h.valid_from as update
      from contact_history ch
      join history h on ch.historyid = h.id
    SQL
    result_entries(sql: sql)
  end

  def legacy_domain_data
    @legacy_domain_data ||= legacy_domains
  end

  def legacy_domains
    sql = <<~SQL.gsub(/\s+/, " ").strip
      select distinct id, name from object_registry
      where type = 3
    SQL
    result_entries(sql: sql)
  end

  def legacy_contact_data
    @legacy_contact_data ||= legacy_contacts
  end

  def legacy_contacts
    sql = <<~SQL.gsub(/\s+/, " ").strip
      select distinct id, name
      from contact
    SQL
    result_entries(sql: sql)
  end
end

