# frozen_string_literal: true

require 'resolv'

class NameserverRecordValidationJob < ApplicationJob
  include Dnsruby

  def perform(nameserver = nil)
    if nameserver.nil?
      Nameserver.all.map do |nameserver|
        result = Domains::NameserverValidator.run(hostname: nameserver.hostname)

        if result[:result]
          true
        else
          parse_result(result, nameserver)
          false
        end
      end
    else
      result = Domains::NameserverValidator.run(hostname: nameserver.hostname)
      return parse_result(result, nameserver) unless result[:result]

      true
    end
  end

  private

  def parse_result(result, nameserver)
    text = ""
    case result[:reason]
    when 'authority'
      text = "Authority information about nameserver hostname **#{nameserver.hostname}** doesn't present"
    when 'serial'
      text = "Serial number for nameserver hostname **#{nameserver.hostname}** doesn't present"
    when 'not found'
      text = "Seems nameserver hostname **#{nameserver.hostname}** doesn't exist"
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
    nameserver.domain.registrar.notifications.create!(text: text)
  end

  def logger
    @logger ||= Rails.logger
  end
end
