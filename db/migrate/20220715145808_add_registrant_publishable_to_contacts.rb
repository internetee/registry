class AddRegistrantPublishableToContacts < ActiveRecord::Migration[6.1]
  def change
    add_column :contacts, :registrant_publishable, :boolean, default: false
  end
end
