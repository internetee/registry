module DomainVersionObserver
  extend ActiveSupport::Concern

  included do
    after_save :delayed_whois_update
  end

  private

  def delayed_whois_update
    name = domain_name
    return unless name
    body = snapshot
    delay.update_private_whois(name, body)
    delay.update_public_whois(name, body)
  end

  def update_private_whois(domain_name, body)
    wd = Whois::PublicDomain.find_or_initialize_by(name: domain_name)
    wd.body = body
    wd.save!
  end

  def update_public_whois(domain_name, body)
    wd = Whois::PrivateDomain.find_or_initialize_by(name: domain_name)
    wd.body = body
    wd.save!
  end

  def domain_name
    name = reify.try(:name)
    name = load_snapshot[:domain][:name] if event == 'create'
    return name if name
  end
end
