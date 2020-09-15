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
    # country_code = uid.slice(0..1)

    find_by(identity_code: identity_code)
  end

  # rubocop:disable Metrics/AbcSize
  def tampered_with?(omniauth_hash)
    uid_from_hash = omniauth_hash['uid']
    provider_from_hash = omniauth_hash['provider']

    begin
      uid != uid_from_hash ||
        provider != provider_from_hash ||
        country_code != uid_from_hash.slice(0..1) ||
        identity_code != uid_from_hash.slice(2..-1) ||
        given_names != omniauth_hash.dig('info', 'first_name') ||
        surname != omniauth_hash.dig('info', 'last_name')
    end
  end
  # rubocop:enable Metrics/AbcSize

  def self.from_omniauth(omniauth_hash)
    uid = omniauth_hash['uid']
    provider = omniauth_hash['provider']

    User.find_or_initialize_by(provider: provider, uid: uid) do |user|
      user.given_names = omniauth_hash.dig('info', 'first_name')
      user.surname = omniauth_hash.dig('info', 'last_name')
      if provider == TARA_PROVIDER
        user.country_code = uid.slice(0..1)
        user.identity_code = uid.slice(2..-1)
      end
    end
  end

>>>>>>> Add Tara field to users, add routes & controller
end
