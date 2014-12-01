class ZonefileSetting < ActiveRecord::Base
  validates :origin, :ttl, :refresh, :retry, :expire, :minimum_ttl, :email, presence: true
  validates :ttl, :refresh, :retry, :expire, :minimum_ttl, numericality: { only_integer: true }
  def to_s
    origin
  end
end
