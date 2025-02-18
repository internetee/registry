class UserCertificate < ApplicationRecord
  belongs_to :user

  validates :user, presence: true
  validates :private_key, presence: true

  enum status: {
    pending: 'pending',
    active: 'active',
    revoked: 'revoked'
  }

  def renewable?
    return false unless certificate.present?
    return false if revoked?
    
    expires_at.present? && expires_at < 30.days.from_now
  end

  def expired?
    return false unless certificate.present?
    return false if revoked?
    
    expires_at.present? && expires_at < Time.current
  end

  def renew
    raise "Certificate cannot be renewed" unless renewable?

    generator = Certificates::CertificateGenerator.new(
      username: user.username,
      registrar_code: user.registrar_code,
      registrar_name: user.registrar_name,
      user_certificate: self
    )

    generator.renew_certificate
  end

  def self.generate_certificates_for_api_user(api_user:)
    cert = UserCertificate.create!(
      user: api_user,
      status: 'pending',
      private_key: ''
    )

    Certificates::CertificateGenerator.new(
      username: api_user.username,
      registrar_code: api_user.registrar_code,
      registrar_name: api_user.registrar_name,
      user_certificate: cert
    ).call
  end
end
