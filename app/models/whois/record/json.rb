module Whois
  class Record::JSON
    def initialize(domain_name:)
      @domain_name = domain_name
    end

    def generate
      raise NotImplementedError
    end

    protected

    attr_reader :domain_name
  end
end
