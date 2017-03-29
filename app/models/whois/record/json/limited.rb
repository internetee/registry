module Whois
  class Record::JSON::Limited < JSON
    def generate
      data = {}

      data['name'] = domain_name.name
      data['status'] = status

      data
    end

    private

    def status
      if domain_name.reserved? && domain_name.disputed?
        %w[Reserved Disputed]
      elsif domain_name.reserved?
        %w[Reserved]
      elsif domain_name.disputed?
        %w[Disputed]
      end
    end
  end
end
