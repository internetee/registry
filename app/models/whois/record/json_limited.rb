module Whois
  class Record::JSONLimited
    def initialize(domain_name:)
      @domain_name = domain_name
    end

    def generate
      data = HashWithIndifferentAccess.new

      data[:name] = domain_name.name
      data[:status] = status

      data
    end

    private

    attr_reader :domain_name

    def status
      if domain_name.reserved? && domain_name.disputed?
        %w[Reserved Disputed]
      elsif domain_name.reserved?
        %w[Reserved]
      elsif domain_name.disputed?
        %w[Disputed]
      elsif domain_name.blocked?
        %w[Blocked]
      end
    end
  end
end
