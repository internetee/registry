class RemoveRegistrarBillingAddress < ActiveRecord::Migration[6.0]
  def change
    remove_column :registrars, :billing_address
  end
end
