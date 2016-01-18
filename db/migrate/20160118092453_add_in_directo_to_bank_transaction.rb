class AddInDirectoToBankTransaction < ActiveRecord::Migration
  def change
    add_column :bank_transactions, :in_directo, :boolean, default: false
  end
end
