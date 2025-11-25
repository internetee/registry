class AddExpiredAtToReservedDomains < ActiveRecord::Migration[6.1]
  def change
    add_column :reserved_domains, :expire_at, :datetime, null: true
  end
end
