class AddAutoRenewToDomains < ActiveRecord::Migration[6.1]
  def change
    add_column :domains, :auto_renew, :boolean, null: false, default: false
  end
end
