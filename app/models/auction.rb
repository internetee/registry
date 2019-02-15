class Auction < ActiveRecord::Base
  enum status: {
    started: 'started',
    awaiting_payment: 'awaiting_payment',
    no_bids: 'no_bids',
    payment_received: 'payment_received',
    payment_not_received: 'payment_not_received',
    domain_registered: 'domain_registered',
    domain_not_registered: 'domain_not_registered',
  }

  PENDING_STATUSES = [statuses[:started],
                      statuses[:awaiting_payment],
                      statuses[:payment_received]].freeze
  private_constant :PENDING_STATUSES

  def self.sell(domain_name)
    create!(domain: domain_name.to_s, status: statuses[:started])
  end

  def self.pending(domain_name)
    find_by(domain: domain_name.to_s, status: PENDING_STATUSES)
  end

  def mark_as_no_bids
    transaction do
      DNS::DomainName.new(domain).update_whois
      no_bids!
    end
  end

  def mark_as_payment_received
    self.status = self.class.statuses[:payment_received]
    generate_registration_code
    save!
  end

  def mark_as_payment_not_received
    self.status = self.class.statuses[:payment_not_received]

    transaction do
      save!
      restart
    end
  end

  def mark_as_domain_not_registered
    self.status = self.class.statuses[:domain_not_registered]

    transaction do
      save!
      restart
    end
  end

  def domain_registrable?(registration_code = nil)
    payment_received? && registration_code_matches?(registration_code)
  end

  private

  def generate_registration_code
    self.registration_code = SecureRandom.hex
  end

  def restart
    self.class.create!(domain: domain, status: self.class.statuses[:started])
  end

  def registration_code_matches?(code)
    registration_code == code
  end
end
