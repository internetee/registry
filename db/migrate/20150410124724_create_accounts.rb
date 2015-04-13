class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.integer :registrar_id
      t.string :account_type
      t.decimal :balance

      t.timestamps
    end

    Registrar.all.each do |x|
      Account.create(registrar_id: x.id, account_type: Account::CASH)
    end
  end
end
