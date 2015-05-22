class UpdateCerts < ActiveRecord::Migration
  def change
    Certificate.all.each do |x|
      if x.crt.present? && x.csr.present?
        x.interface = Certificate::REGISTRAR
        x.md5 = OpenSSL::Digest::MD5.new(x.parsed_crt.to_der).to_s
      elsif x.crt.present? && x.csr.blank?
        x.interface = Certificate::API
        x.md5 = OpenSSL::Digest::MD5.new(x.parsed_crt.to_der).to_s
      elsif x.crt.blank? && x.csr.present?
        x.interface = Certificate::REGISTRAR
      end
      x.save
    end
  end
end
