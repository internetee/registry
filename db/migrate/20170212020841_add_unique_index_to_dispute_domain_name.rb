class AddUniqueIndexToDisputeDomainName < ActiveRecord::Migration
  def change
    add_index :disputes, :domain_name, unique: true
  end
end
