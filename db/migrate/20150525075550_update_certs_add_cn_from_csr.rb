class UpdateCertsAddCnFromCsr < ActiveRecord::Migration
  def change
    Certificate.all.each do |x|
      if x.crt.blank? && x.csr.present?
        pc = x.parsed_crt.try(:subject).try(:to_s) || ''
        cn = pc.scan(/\/CN=(.+)/).flatten.first
        x.common_name = cn.split('/').first
      end
      x.save
    end
  end
end
