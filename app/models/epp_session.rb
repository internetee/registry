class EppSession < ActiveRecord::Base
  belongs_to :user, required: true

  validates :session_id, uniqueness: true, presence: true

  def self.limit_per_registrar
    4
  end

  def self.limit_reached?(registrar)
    count = where(user_id: registrar.api_users.ids).where('updated_at >= ?', Time.zone.now - 1.second).count
    count >= limit_per_registrar
  end
end
