class AddCertCommonName < ActiveRecord::Migration[5.1]
  def self.up
    # Certificate.all.each do |x|
    #   if x.crt.blank? && x.csr.present?
    #     pc = x.parsed_csr.try(:subject).try(:to_s) || ''
    #     cn = pc.scan(/\/CN=(.+)/).flatten.first
    #     x.common_name = cn.split('/').first
    #   end
    #   x.save
    # end
  end

  def self.down
  end
end
