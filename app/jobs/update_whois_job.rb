class UpdateWhoisJob < Que::Job
  def run(domain_name)
    DNS::DomainName.update_whois(domain_name: domain_name)
  end
end
