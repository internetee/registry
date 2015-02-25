class CreateCertificates < ActiveRecord::Migration
  def change
    create_table :certificates do |t|
      t.integer :api_user_id
      t.text :csr
      t.text :crt

      t.timestamps
    end

    ApiUser.all.each do |x|
      x.certificates << Certificate.new(crt: x.crt, csr: x.csr)
    end
  end
end
