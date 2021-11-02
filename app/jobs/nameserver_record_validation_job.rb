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
    return compile_event_data(result: false, reason: "Nameserver doesn't respond") unless validate_hostname_respond(nameserver)
    return compile_event_data(result: false, reason: "No domain related to Nameserver") unless validate_domain(nameserver)

    compile_event_data(result: true, reason: nil)
  end

  def compile_event_data(result:, reason:)
    {
       "result" => {
         "result" => "#{result}"
        },
       "event_data" =>
          {
            "errors" => "",
            "check_level" => 'ns',
            "email" => "",
            "reason" => "#{reason}"
          }
      }
  end

  def validate_domain(nameserver)
    nameserver.domain
  end

  def validate_hostname_respond(nameserver)
    return true if Resolv.getaddress nameserver.hostname
  rescue Resolv::ResolvError
    false
  end

  def glue_record_required?(nameserver)
    return false unless nameserver.hostname? && nameserver.domain

    DomainName(nameserver.hostname).domain == nameserver.domain.name
  end


  def check_validation_info(result: , nameserver:)
    event_data = result["event_data"]
    result = result["result"]["result"]

    add_to_validation_table(result: result, nameserver: nameserver, event_data: event_data)
  end

  def add_to_validation_table(result:, nameserver:, event_data:)
    nameserver.validation_events.create(
      event_data: event_data,
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
