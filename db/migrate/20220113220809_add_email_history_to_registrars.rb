class AddEmailHistoryToRegistrars < ActiveRecord::Migration[6.1]
  def change
    add_column :registrars, :email_history, :string

    reversible do |dir|
      dir.up { Registrar.update_all('email_history = email') }
    end
  end
end
