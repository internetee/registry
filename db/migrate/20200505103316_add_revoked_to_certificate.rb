class AddRevokedToCertificate < ActiveRecord::Migration[5.2]
  def change
    add_column :certificates, :revoked, :boolean, null: false, default: false
  end
end
