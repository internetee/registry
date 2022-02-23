class AddEmailHistoryToContacts < ActiveRecord::Migration[6.1]
  def change
    add_column :contacts, :email_history, :string

    reversible do |dir|
      dir.up { Contact.update_all('email_history = email') }
    end
  end
end
