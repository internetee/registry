class AddCurrencyToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :currency, :string

    Account.update_all(currency: 'EUR')
  end
end
