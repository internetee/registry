module Whois
  class ContactRequest < Server
    self.table_name = 'contact_requests'

    STATUS_NEW       = 'new'.freeze
    STATUS_CONFIRMED = 'confirmed'.freeze
    STATUS_SENT      = 'sent'.freeze
    STATUSES         = [STATUS_NEW, STATUS_CONFIRMED, STATUS_SENT].freeze

    validates :whois_record_id, presence: true
    validates :email, presence: true
    validates :name, presence: true
    validates :status, inclusion: { in: STATUSES }

    attr_readonly :secret,
                  :valid_to

    def self.record(params)
      contact_request = new(params)
      contact_request.secret = create_random_secret
      contact_request.valid_to = set_valid_to_at_24_hours_from_now
      contact_request.status = STATUS_NEW
      contact_request.save!
    end

    def self.create_random_secret
      SecureRandom.hex(64)
    end

    def self.set_valid_to_at_24_hours_from_now
      (Time.zone.now + 24.hours)
    end
  end
end
