# frozen_string_literal: true
require 'resolv'

class NameserverRecordValidationJob < ApplicationJob
  def perform(nameserver = nil)
    if nameserver.nil?
      Nameserver.all.map do |nameserver|
        result = validate(nameserver)
        check_validation_info(result: result, nameserver: nameserver)
      end
    else
      result = validate(nameserver)
      check_validation_info(result: result, nameserver: nameserver)
    end
  end

  private

  def validate(nameserver)
    # validate_glue_records(nameserver) && validate_domain_name(nameserver)
    # validate_glue_records(nameserver)
    validate_hostname(nameserver)
  end

  def validate_hostname(nameserver)
    return true if Resolv.getaddress nameserver.hostname
  rescue Resolv::ResolvError
    false
  end

  # if the hostname has the same domain name as the domain to which it belongs, then you need to add the IP addresses
  # def validate_glue_records(nameserver)
  #   # binding.pry
  #   if glue_record_required?(nameserver)
  #     return false if nameserver.ipv6.empty? && nameserver.ipv4.empty?
  #   else
  #     true
  #   end
  # end

  def glue_record_required?(nameserver)
    return false unless nameserver.hostname? && nameserver.domain

    DomainName(nameserver.hostname).domain == nameserver.domain.name
  end


  def check_validation_info(result: , nameserver: )
    add_to_validation_table(result: result, nameserver: nameserver)

    result
  end

  def add_to_validation_table(result:, nameserver:)
    nameserver.validation_events.create(
      event_data: 'data',
      success: result,
      validation_eventable_type: 'Nameserver',
      validation_eventable_id: nameserver.id,
      event_type: ValidationEvent::EventType::TYPES[:nameserver_validation]
    )
  end

  def make_some_action
    inform_to_tech_contact
    inform_to_registrar
  end

  def inform_to_tech_contact
    return
  end

  def inform_to_registrar
    return
  end
end
