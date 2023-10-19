# frozen_string_literal: true

class BsaProtectedDomain < ApplicationRecord
  include BsaProtectedDomain::Ransackable

  NEW = 'New'
  QUEUED_FOR_ACTIVATION = 'QueuedForActivation'
  ACTIVATION_IN_PROGRESS = 'ActivationInProgress'
  ACTIVE = 'Active'
  QUEUED_FOR_RELEASE = 'QueuedForRelease'
  RELEASE_IN_PROGRESS = 'ReleaseInProgress'
  CLOSED = 'Closed'

  enum state: {
    NEW => 1,
    QUEUED_FOR_ACTIVATION => 2,
    ACTIVATION_IN_PROGRESS => 3,
    ACTIVE => 4,
    QUEUED_FOR_RELEASE => 5,
    RELEASE_IN_PROGRESS => 6,
    CLOSED => 7
  }

  class << self
    def pw_for(domain_name)
      name_in_ascii = SimpleIDN.to_ascii(domain_name)
      by_domain(domain_name).first.try(:registration_code) || by_domain(name_in_ascii).first.try(:registration_code)
    end

    def by_domain(name)
      where(domain_name: name)
    end

    def new_password_for(name)
      record = by_domain(name).first
      return unless record

      record.regenerate_password
      record.save
    end
  end

  def generate_data
    return if Domain.where(name: name).any?

    wr = Whois::Record.find_or_initialize_by(name: name)
    wr.json = @json = generate_json(wr, domain_status: 'Reserved') # we need @json to bind to class
    wr.save
  end
  alias_method :update_whois_record, :generate_data

  def regenerate_password
    self.registration_code = SecureRandom.hex
  end
end
