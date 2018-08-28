class AuthTokenCreator
  DEFAULT_VALIDITY = 2.hours

  attr_reader :user
  attr_reader :key
  attr_reader :expires_at

  def self.create_with_defaults(user)
    new(user, Rails.application.config.secret_key_base, Time.now + DEFAULT_VALIDITY)
  end

  def initialize(user, key, expires_at)
    @user = user
    @key = key
    @expires_at = expires_at.utc.strftime('%F %T %Z')
  end

  def hashable
    {
      user_ident: user.registrant_ident,
      user_username: user.username,
      expires_at: expires_at,
    }.to_json
  end

  def encrypted_token
    encryptor = OpenSSL::Cipher::AES.new(256, :CBC)
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
