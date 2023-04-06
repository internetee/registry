class Auction < ApplicationRecord
  enum status: {
    started: 'started',
    awaiting_payment: 'awaiting_payment',
    no_bids: 'no_bids',
    payment_received: 'payment_received',
    payment_not_received: 'payment_not_received',
    domain_registered: 'domain_registered',
    domain_not_registered: 'domain_not_registered',
  }

  enum platform: %i[auto manual]

  PENDING_STATUSES = [statuses[:started],
                      statuses[:awaiting_payment],
                      statuses[:payment_received]].freeze

  private_constant :PENDING_STATUSES

  scope :with_status, ->(status) {
    where(status: status) if status.present?
  }

  scope :with_start_created_at_date, ->(start_created_at) {
    where('created_at >= ?', start_created_at) if start_created_at.present?
  }

  scope :with_end_created_at_date, ->(end_created_at) {
    where('created_at <= ?', end_created_at) if end_created_at.present?
  }

  scope :with_domain_name, ->(domain_name) {
    where('domain ilike ?', "%#{domain_name.strip}%") if domain_name.present?
  }

  def self.ransackable_associations(*)
    authorizable_ransackable_associations
  end

  def self.ransackable_attributes(*)
    authorizable_ransackable_attributes
  end

  def self.pending(domain_name)
    find_by(domain: domain_name.to_s, status: PENDING_STATUSES)
  end

  def self.domain_exists_in_blocked_disputed_and_registered?(domain_name)
    Domain.exists?(name: domain_name) ||
      BlockedDomain.exists?(name: domain_name) ||
      Dispute.exists?(domain_name: domain_name) ||
      exception_for_registred_or_unbided_existed_auctions(domain_name)
  end

  def self.exception_for_registred_or_unbided_existed_auctions(domain_name)
    return false unless Auction.exists?(domain: domain_name)

    auctions = Auction.where(domain: domain_name).order(:created_at)
    last_record = auctions.last

    return false if last_record.domain_registered? || last_record.no_bids?

    true
  end

  def start
    self.status = self.class.statuses[:started]
    save!
  end

  def whois_deadline
    registration_deadline.try(:to_s, :iso8601)
  end

  def mark_as_no_bids
    no_bids!
  end

  def mark_deadline(registration_deadline)
    self.registration_deadline = registration_deadline
    save!
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

  def restart
    new_platform = platform.nil? ? :auto : platform

    new_auction = self.class.new(domain: domain, platform: new_platform)
    new_auction.start
  end

  private

  def generate_registration_code
    self.registration_code = SecureRandom.hex
  end

  def registration_code_matches?(code)
    registration_code == code
  end
end
