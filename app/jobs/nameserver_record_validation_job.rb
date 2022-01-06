# frozen_string_literal: true

require 'resolv'

class NameserverRecordValidationJob < ApplicationJob
  include Dnsruby

  def perform(domain_name: nil)
    if domain_name.nil?
      domains = Domain.all.select { |domain| domain.nameservers.exists? }.
                           select { |domain| domain.created_at < Time.zone.now - 8.hours }

      domains.each do |domain|
        domain.nameservers.each do |nameserver|
          result = NameserverValidator.run(domain_name: domain.name, hostname: nameserver.hostname)

          if result[:result]
            true
          else
            parse_result(result, nameserver)
            false
          end
        end
      end
    else
      domain = Domain.find_by(name: domain_name)

      return logger.info 'Domain not found' if domain.nil?
      return logger.info 'It should take 8 hours after the domain was created' if domain.created_at > Time.zone.now - 8.hours
      return logger.info 'Domain not has nameservers' if domain.nameservers.empty?

      domain.nameservers.each do |nameserver|
        result = NameserverValidator.run(domain_name: domain.name, hostname: nameserver.hostname)

        if result[:result]
          true
        else
          parse_result(result, nameserver)
          false
        end
      end
    end
  end

  private

  def parse_result(result, nameserver)
    text = ""
    case result[:reason]
    when 'answer'
      text = "No any answer come from **#{nameserver}**"
    when 'serial'
      text = "Serial number for nameserver hostname **#{nameserver}** doesn't present. Seems nameservers out the zone"
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
