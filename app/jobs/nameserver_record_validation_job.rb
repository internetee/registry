# frozen_string_literal: true

require 'resolv'

class NameserverRecordValidationJob < ApplicationJob
  def perform(nameserver = nil)
    if nameserver.nil?
      Nameserver.all.map do |nameserver|
        result = validate(nameserver)
        inform_to_registrar(nameserver) unless result
      end
    else
      result = validate(nameserver)
      inform_to_registrar(nameserver) unless result
    end
  end

  private

  def validate(nameserver)
      return true if Resolv.getaddress nameserver.hostname
  rescue Resolv::ResolvError
      false
  end

  # def glue_record_required?(nameserver)
  #   return false unless nameserver.hostname? && nameserver.domain
  #
  #   DomainName(nameserver.hostname).domain == nameserver.domain.name
  # end

  def inform_to_tech_contact
    return
  end

  def inform_to_registrar(nameserver)
    nameserver.domain.registrar.notifications.create!(text: "Nameserver doesn't response")
  end
end
