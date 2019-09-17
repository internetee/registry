class EppSession < ApplicationRecord
  belongs_to :user, required: true

  validates :session_id, uniqueness: true, presence: true

  class_attribute :timeout
  self.timeout = (ENV['epp_session_timeout_seconds'] || 300).to_i.seconds

  class_attribute :limit_per_registrar
  self.limit_per_registrar = (ENV['epp_session_limit_per_registrar'] || 4).to_i

  alias_attribute :last_access, :updated_at

  def self.limit_reached?(registrar)
    count = where(user_id: registrar.api_users.ids).count
    count >= limit_per_registrar
  end

  def self.expired
    interval = "#{timeout.parts.first.second} #{timeout.parts.first.first}"
    where(':now > (updated_at + interval :interval)', now: Time.zone.now, interval: interval)
  end

  def update_last_access
    touch
  end

  def timed_out?
    (updated_at + self.class.timeout).past?
  end

  def expired?
    timed_out?
  end
end
