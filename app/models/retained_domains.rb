# Hiding the queries behind its own class will allow us to include disputed or
# auctioned domains without meddling up with controller logic.
class RetainedDomains
  RESERVED = 'reserved'.freeze
  BLOCKED = 'blocked'.freeze

  attr_reader :domains

  def initialize
    @domains = gather_domains
  end

  def gather_domains
    blocked_domains = BlockedDomain.order(name: :desc).all
    reserved_domains = ReservedDomain.order(name: :desc).all

    domains = blocked_domains.to_a.union(reserved_domains.to_a)

    domains.sort_by(&:name)
  end

  def to_jsonable
    domains.map { |el| domain_to_json(el) }
  end

  def domain_to_json(domain)
    # Smelly, but ActiveRecord objects are weird and do not respond
    # to usual syntax:
    #   case a
    #   when Array then "foo"
    #   when Hash then "bar"
    #   else "baz"
    #   end
    status = case domain.class.to_s
             when 'ReservedDomain' then RESERVED
             when 'BlockedDomain' then BLOCKED
             end

    punycode = SimpleIDN.to_ascii(domain.name)

    {
      name: domain.name,
      status: status,
      punycode_name: punycode
    }
  end

  def count
    domains.count
  end
end
