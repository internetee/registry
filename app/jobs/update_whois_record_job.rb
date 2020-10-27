class UpdateWhoisRecordJob < ApplicationJob
  queue_as :default

  def perform(names, type)
    ::PaperTrail.request.whodunnit = "job - #{self.class.name} - #{type}"

    klass = determine_class(type)

    Array(names).each do |name|
      record = find_record(klass, name)
      if record
        send "update_#{type}", record
      else
        send "delete_#{type}", name
      end
    end
  end

  def find_record(klass, name)
    klass == DNS::Zone ? klass.find_by(origin: name) : klass.find_by(name: name)
  end

  def determine_class(type)
    case type
    when 'reserved' then ReservedDomain
    when 'blocked'  then BlockedDomain
    when 'domain'   then Domain
    when 'disputed' then Dispute.active
    when 'zone'     then DNS::Zone
    end
  end

  def update_domain(domain)
    domain.whois_record ? domain.whois_record.save : domain.create_whois_record
  end

  def update_reserved(record)
    record.generate_data
  end

  def update_blocked(record)
    update_reserved(record)
  end

  def update_disputed(record)
    update_reserved(record)
  end

  def update_zone(record)
    update_reserved(record)
  end

  # 1. deleting own
  # 2. trying to regenerate reserved in order domain is still in the list
  def delete_domain(name)
    WhoisRecord.where(name: name).destroy_all

    BlockedDomain.find_by(name: name).try(:generate_data)
    ReservedDomain.find_by(name: name).try(:generate_data)
    Dispute.active.find_by(domain_name: name).try(:generate_data)
  end

  def delete_reserved(name)
    remove_status_from_whois(domain_name: name, domain_status: 'Reserved')
  end

  def delete_blocked(name)
    delete_reserved(name)
  end

  def delete_disputed(name)
    return if Dispute.active.find_by(domain_name: name).present?

    remove_status_from_whois(domain_name: name, domain_status: 'disputed')
  end

  def delete_zone(name)
    WhoisRecord.where(name: name).destroy_all
    Whois::Record.where(name: name).destroy_all
  end

  def remove_status_from_whois(domain_name:, domain_status:)
    Whois::Record.where(name: domain_name).each do |r|
      r.json['status'] = r.json['status'].delete_if { |status| status == domain_status }
      r.json['status'].blank? ? r.destroy : r.save
    end
  end
end
