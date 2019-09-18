class EppSession < ActiveRecord::Base
  belongs_to :user, required: true

  validates :session_id, uniqueness: true, presence: true

  class_attribute :timeout
  self.timeout = ENV['epp_session_timeout_seconds'].to_i.seconds

  alias_attribute :last_access, :updated_at

  def self.limit_per_registrar
    4
  end

  def self.limit_reached?(registrar)
    count = where(user_id: registrar.api_users.ids).where('updated_at >= ?', Time.zone.now - 1.second).count
    count >= limit_per_registrar
  end

  def self.expired
    timeout_interval_sql = "#{timeout.parts.first.second} #{timeout.parts.first.first}"
    where(":now > (updated_at + interval '#{timeout_interval_sql}')", now: Time.zone.now)
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
