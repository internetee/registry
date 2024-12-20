class FreeDomainReservationHolder < ApplicationRecord
  before_validation :set_user_unique_id
  validates :user_unique_id, presence: true, uniqueness: true

  def reserved_domains
    ReservedDomain.where(name: domain_names)
  end

  def output_reserved_domains
    reserved_domains.map do |domain|
      {
        name: domain.name,
        password: domain.password,
        expire_at: domain.expire_at
      }
    end
  end

  private

  def set_user_unique_id
    self.user_unique_id = SecureRandom.uuid[0..9]
  end
end
