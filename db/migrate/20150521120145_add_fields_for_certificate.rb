class AddFieldsForCertificate < ActiveRecord::Migration
  def change
    add_column :certificates, :common_name, :string
    add_column :certificates, :md5, :string
    add_column :certificates, :interface, :string
  end
end
