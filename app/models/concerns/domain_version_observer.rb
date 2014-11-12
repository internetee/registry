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
    delay.update_whois(name, body)
  end

  # not sure we need to pass in the params since i don't know if delayed job has access to
  # all the regular attributes and stuff
  def update_whois(domain_name, body)
    wd = WhoisDomain.find_or_initialize_by(name: domain_name)
    wd.body = body
    wd.save!
  end

  def domain_name
    name = reify.try(:name)
    name = load_snapshot[:domain][:name] if event == 'create'
    return name if name
  end
end
