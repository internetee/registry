class AddMoreFieldsToRegistrar < ActiveRecord::Migration
  def change
    add_column :registrars, :phone, :string
    add_column :registrars, :email, :string
    add_column :registrars, :billing_email, :string
  end
end
