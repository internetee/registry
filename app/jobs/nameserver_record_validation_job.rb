# frozen_string_literal: true

require 'resolv'

class NameserverRecordValidationJob < ApplicationJob
  include Dnsruby

  def perform(domain_name: nil, nameserver_address: nil)
    if nameserver_address.nil?
      Nameserver.all.map do |nameserver|
        result = Domains::NameserverValidator.run(hostname: nameserver.domain.name, nameserver_address: nameserver.hostname)

        if result[:result]
          true
        else
          parse_result(result, nameserver)
          false
        end
      end
    else
      result = Domains::NameserverValidator.run(hostname: domain_name, nameserver_address: nameserver_address)
      return parse_result(result, nameserver_address) unless result[:result]

      true
    end
  end

  private

  def parse_result(result, nameserver)
    text = ""
    case result[:reason]
    when 'answer'
      text = "No any answer come from **#{nameserver}**"
    when 'serial'
      text = "Serial number for nameserver hostname **#{nameserver}** doesn't present"
    when 'not found'
      text = "Seems nameserver hostname **#{nameserver}** doesn't exist"
    when 'exception'
      text = "Something goes wrong, exception name: **#{result[:error_info]}**"
    end

    logger.info text
    failed_log(text: text, nameserver: nameserver)

    false
  end

  def failed_log(text:, nameserver:)
    inform_to_tech_contact(text)
    inform_to_registrar(text: text, nameserver: nameserver)

    false
  end

  def inform_to_tech_contact(text)
    "NEED TO DO!"
    text
  end

  def inform_to_registrar(text:, nameserver:)
    # nameserver.domain.registrar.notifications.create!(text: text)
    "NEED TO DO!"
  end

  def logger
    @logger ||= Rails.logger
  end
end
