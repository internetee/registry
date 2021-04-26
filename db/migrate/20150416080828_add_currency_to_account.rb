class AddCurrencyToAccount < ActiveRecord::Migration[6.0]
  def change
    add_column :accounts, :currency, :string
  end
end
