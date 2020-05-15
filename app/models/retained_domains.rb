# Hiding the queries behind its own class will allow us to include disputed or
# auctioned domains without meddling up with controller logic.
class RetainedDomains
  RESERVED = 'reserved'.freeze
  BLOCKED = 'blocked'.freeze

  attr_reader :domains,
              :type

  def initialize(params)
    @type = establish_type(params)
    @domains = gather_domains
  end

  delegate :count, to: :domains

  def to_jsonable
    domains.map { |el| domain_to_jsonable(el) }
  end

  private

  def establish_type(params)
    type = params[:type]

    case type
    when RESERVED then :reserved
    when BLOCKED then :blocked
    else :all
    end
  end

  def gather_domains
    domains = blocked_domains.to_a.union(reserved_domains.to_a)

    domains.sort_by(&:name)
  end

  def blocked_domains
    if %i[all blocked].include?(type)
      BlockedDomain.order(name: :desc).all
    else
      []
    end
  end

  def reserved_domains
    if %i[all reserved].include?(type)
      ReservedDomain.order(name: :desc).all
    else
      []
    end
  end

  def domain_to_jsonable(domain)
    status = case domain
             when ReservedDomain then RESERVED
             when BlockedDomain then BLOCKED
             end

    punycode = SimpleIDN.to_ascii(domain.name)

    {
      name: domain.name,
      status: status,
      punycode_name: punycode,
    }
  end
end
