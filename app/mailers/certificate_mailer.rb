class CertificateMailer < ApplicationMailer
  def certificate_signing_requested(email:, api_user:, csr:)
    @certificate = csr
    @api_user = api_user
    subject = 'New Certificate Signing Request Received'
    mail(to: email, subject: subject)
  end

  def signed(email:, api_user:, crt:)
    @crt = crt
    @api_user = api_user
    subject = 'Certificate Signing Confirmation'
    mail(to: email, subject: subject)
  end

  def certificate_expiring(email:, certificate:)
    @certificate = certificate
    subject = 'Certificate Expiring'
    mail(to: email, subject: subject)
  end
end
