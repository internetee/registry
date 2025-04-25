# app/models/concerns/certificate_concern.rb
module Certificate::CertificateConcern
  extend ActiveSupport::Concern

  class_methods do
    def parse_md_from_string(crt)
      return if crt.blank?

      crt = crt.split(' ').join("\n")
      crt.gsub!("-----BEGIN\nCERTIFICATE-----\n", "-----BEGIN CERTIFICATE-----\n")
      crt.gsub!("\n-----END\nCERTIFICATE-----", "\n-----END CERTIFICATE-----")
      cert = OpenSSL::X509::Certificate.new(crt)
      OpenSSL::Digest::MD5.new(cert.to_der).to_s
    end
  end
end
