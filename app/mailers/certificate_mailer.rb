class CertificateMailer < ApplicationMailer
  def new_certificate_signing_request(email:, api_user:, csr:)
    @certificate = csr
    @api_user = api_user
    subject = 'New Certificate Signing Request Received'
    mail(to: email, subject: subject)
  end
end
