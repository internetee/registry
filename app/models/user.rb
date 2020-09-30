class User < ApplicationRecord
  include Versions # version/user_version.rb

  ESTONIAN_COUNTRY_CODE = 'EE'.freeze
  TARA_PROVIDER = 'tara'.freeze

  has_many :actions, dependent: :restrict_with_exception

  attr_accessor :phone

  self.ignored_columns = %w[legacy_id]

  def id_role_username
    "#{self.id}-#{self.class}: #{self.username}"
  end

  def self.from_omniauth(omniauth_hash)
    uid = omniauth_hash['uid']
    identity_code = uid.slice(2..-1)
    country_code = uid.slice(0..1)

    User.find_by(identity_code: identity_code, country_code: country_code)
  end
end
