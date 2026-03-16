class FreeDomainReservationHolder < ApplicationRecord
  before_validation :set_user_unique_id
  validates :user_unique_id, presence: true, uniqueness: true

  def reserved_domains
    ReservedDomain.where(name: domain_names)
  end

  def output_reserved_domains
    domain_names.map do |name|
      domain = ReservedDomain.find_by(name: name)
      registered = Domain.exists?(name: name)

      if registered
        { name: name, status: 'registered' }
      elsif domain
        { name: name, password: domain.password, expire_at: domain.expire_at, status: 'reserved' }
      else
        { name: name, status: 'expired' }
      end
    end
  end

  private

  def set_user_unique_id
    self.user_unique_id = SecureRandom.uuid[0..9]
  end
end
