class AuthTokenDecryptor
  attr_reader :decrypted_data
  attr_reader :token
  attr_reader :key
  attr_reader :user

  def self.create_with_defaults(token)
    self.new(token, Rails.application.config.secret_key_base)
  end

  def initialize(token, key)
    @token = token
    @key = key
  end

  def decrypt_token
    decipher = OpenSSL::Cipher::AES.new(256, :CBC)
    decipher.decrypt
    decipher.key = key

    base64_decoded = Base64.urlsafe_decode64(token.to_s)
    plain = decipher.update(base64_decoded) + decipher.final

    @decrypted_data = JSON.parse(plain, symbolize_names: true)
  rescue OpenSSL::Cipher::CipherError, ArgumentError
    false
  end

  def valid?
    decrypted_data && valid_user? && still_valid?
  end

  private

  def valid_user?
    @user = RegistrantUser.find_by(registrant_ident: decrypted_data[:user_ident])
    @user&.username == decrypted_data[:user_username]
  end

  def still_valid?
    decrypted_data[:expires_at] > Time.now
  end
end
