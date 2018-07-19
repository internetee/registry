class AuthToken
  def initialize; end

  def generate_token(user, secret = Rails.application.config.secret_key_base)
    cipher = OpenSSL::Cipher::AES.new(256, :CBC)
    expires_at = (Time.now.utc + 2.hours).strftime("%F %T %Z")

    data = {
      username: user.username,
      expires_at: expires_at
    }

    hashable = data.to_json

    cipher.encrypt
    cipher.key = secret
    encrypted = cipher.update(hashable) + cipher.final
    base64_encoded = Base64.encode64(encrypted)

    {
      access_token: base64_encoded,
      expires_at: expires_at,
      type: "Bearer"
    }
  end
end
