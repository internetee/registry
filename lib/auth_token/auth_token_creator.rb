class AuthTokenCreator
  DEFAULT_VALIDITY = 2.hours

  attr_reader :user, :key, :expires_at

  def self.create_with_defaults(user, authenticated_at = nil)
    new(user, Rails.application.config.secret_key_base, Time.now + DEFAULT_VALIDITY, authenticated_at)
  end

  def initialize(user, key, expires_at, authenticated_at = nil)
    @authenticated_at = authenticated_at
    @user = user
    @key = key
    @expires_at = expires_at.utc.strftime('%F %T %Z')
  end

  def hashable
    data = {
      user_ident: user.registrant_ident,
      user_username: user.username,
      expires_at: expires_at,
    }
    data[:authenticated_at] = @authenticated_at if @authenticated_at.present?
    data.to_json
  end

  def encrypted_token
    encryptor = OpenSSL::Cipher.new('aes-256-cbc')
    encryptor.encrypt

    # OpenSSL used to automatically shrink oversized keys, it does not do that any longer.
    # See: https://github.com/ruby/openssl/issues/116
    encryptor.key = key[0..31]
    encrypted_bytes = encryptor.update(hashable) + encryptor.final
    Base64.urlsafe_encode64(encrypted_bytes)
  end

  def token_in_hash
    {
      access_token: encrypted_token,
      expires_at: expires_at,
      type: 'Bearer',
    }
  end
end
