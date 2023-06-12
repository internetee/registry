class AddUniqueIndexToNameInWhoisRecord < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_index :whois_records, :name, unique: true, algorithm: :concurrently
  end
end
