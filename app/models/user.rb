class User < ApplicationRecord
  include Versions # version/user_version.rb

  has_many :actions, dependent: :restrict_with_exception

  scope :admin, -> { where("'admin' = ANY (roles)") }

  attr_accessor :phone

  self.ignored_columns = %w[legacy_id]

  def id_role_username
    "#{id}-#{self.class}: #{username}"
  end

  def self.from_omniauth(omniauth_hash)
    uid = omniauth_hash['uid']
    identity_code = uid&.slice(2..-1)
    # country_code = uid.slice(0..1)

    find_by(identity_code: identity_code, active: true)
  end
end
