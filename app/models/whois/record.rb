module Whois
  class Record < Whois::Server
    self.table_name = 'whois_records'

    validates :domain_name, :body, :json, presence: true

    alias_attribute :domain_name, :name

    def self.regenerate_all
      find_each do |whois_record|
        whois_record.regenerate
      end
    end

    def self.regenerate(domain_name:)
      # whois_record = find_or_initialize_by(domain_name: domain_name.name)
      # whois_record.regenerate
    end

    def regenerate
      touch
    end

    private

    def kind
      # domain_name.registered? ? 'registered' : 'limited'
    end
  end
end
