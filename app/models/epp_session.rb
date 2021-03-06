class EppSession < ApplicationRecord
  belongs_to :user, required: true

  validates :session_id, uniqueness: true, presence: true

  class_attribute :timeout
  self.timeout = (ENV['epp_session_timeout_seconds'] || 300).to_i.seconds

  class_attribute :sessions_per_registrar
  self.sessions_per_registrar = (ENV['epp_sessions_per_registrar'] || 4).to_i

  alias_attribute :last_access, :updated_at

  scope :not_expired,
        lambda {
          where(':now <= (updated_at + interval :interval)', now: Time.zone.now, interval: interval)
        }

  def self.limit_reached?(registrar)
    count = where(user_id: registrar.api_users.ids).not_expired.count
    count >= sessions_per_registrar
  end

  def self.interval
    "#{timeout.parts.first.second} #{timeout.parts.first.first}"
  end

  def self.expired
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
