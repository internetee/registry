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
      whois_record = find_or_initialize_by(domain_name: domain_name.name)

      if !domain_name.registered? && !domain_name.reserved? && !domain_name.disputed? && !domain_name.blocked?
        whois_record.destroy
      else
        whois_record.regenerate
      end
    end

    def regenerate
      generate_json
      generate_body
      save
    end

    private

    def kind
      DNS::DomainName.new(domain_name).registered? ? 'registered' : 'limited'
    end

    def generate_json
      json_class = "::Whois::Record::JSON#{kind.classify}".constantize
      json = json_class.new(domain_name: DNS::DomainName.new(domain_name))
      self[:json] = json.generate
    end

    def generate_body
      template = Rails.root.join("app/views/whois_record/#{kind}.erb")
      body = ERB.new(template.read, nil, '-').result(binding)
      self[:body] = body
    end
  end
end
