module Whois
  class Regeneration
    def initialize(domain_name:)
      @domain_name = domain_name
    end

    def regenerate
      whois_record = Record.find_or_initialize_by(domain_name: domain_name.name)

      if !domain_name.registered? && !domain_name.reserved? && !domain_name.disputed? && !domain_name.blocked?
        whois_record.destroy!
      else
        whois_record.json = json
        whois_record.body = body
        whois_record.save!
      end
    end

    private

    def kind
      domain_name.registered? ? 'registered' : 'limited'
    end

    def json
      json_class = "::Whois::Record::JSON#{kind.classify}".constantize
      json = json_class.new(domain_name: domain_name)
      @json ||= json.generate
    end

    def body
      template = Rails.root.join("app/views/whois_record/#{kind}.erb")
      ERB.new(template.read, nil, '-').result(OpenStruct.new(json: json).send(:binding))
    end

    attr_reader :domain_name
  end
end
