module Whois
  class ContactRequest < Whois::Server
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

    # before_create do
    #   create_random_secret
    #   set_valid_to_at_24_hours_from_now
    # end

    def self.record(params)
      contact_request = self.class.new(params)
      contact_request.secret = create_random_secret
      contact_request.valid_to = set_valid_to_at_24_hours_from_now
      contact_request.save!
    end

    def create_random_secret
      SecureRandom.hex(64)
    end

    def set_valid_to_at_24_hours_from_now
      (Time.zone.now + 24.hours)
    end
  end
end
