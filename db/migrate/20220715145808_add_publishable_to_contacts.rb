class AddPublishableToContacts < ActiveRecord::Migration[6.1]
  def change
    add_column :contacts, :publishable, :boolean, default: false
  end
end
