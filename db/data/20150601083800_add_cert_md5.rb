class AddCertMd5 < ActiveRecord::Migration[5.1]
  def self.up
    # Certificate.all.each do |x|
    #   if x.crt.present? && x.csr.present?
    #     x.interface = Certificate::REGISTRAR
    #     x.md5 = OpenSSL::Digest::MD5.new(x.parsed_crt.to_der).to_s
    #
    #     pc = x.parsed_crt.try(:subject).try(:to_s) || ''
    #     cn = pc.scan(/\/CN=(.+)/).flatten.first
    #     x.common_name = cn.split('/').first
    #   elsif x.crt.present? && x.csr.blank?
    #     x.interface = Certificate::API
    #     x.md5 = OpenSSL::Digest::MD5.new(x.parsed_crt.to_der).to_s
    #
    #     pc = x.parsed_crt.try(:subject).try(:to_s) || ''
    #     cn = pc.scan(/\/CN=(.+)/).flatten.first
    #     x.common_name = cn.split('/').first
    #   elsif x.crt.blank? && x.csr.present?
    #     x.interface = Certificate::REGISTRAR
    #   end
    #   x.save
    # end
  end

  def self.down
  end
end
