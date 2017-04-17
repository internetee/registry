class WhoisRegenerationJob < Que::Job
  def run(domain_name)
    domain_name = DNS::DomainName.new(domain_name)
    Whois::Regeneration.new(domain_name: domain_name).regenerate
  end
end
