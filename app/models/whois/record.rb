module Whois
  class Record < Whois::Server
    self.table_name = 'whois_records'

    validates :domain_name, :body, :json, presence: true

    alias_attribute :domain_name, :name

    def self.regenerate_all
      find_each do |whois_record|
        domain_name = DNS::DomainName.new(whois_record.domain_name)
        regenerate(domain_name: domain_name)
      end
    end

    def self.regenerate(domain_name:)
      WhoisRegenerationJob.enqueue(domain_name.name)
    end
  end
end
