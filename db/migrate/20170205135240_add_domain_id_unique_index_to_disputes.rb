class AddDomainIdUniqueIndexToDisputes < ActiveRecord::Migration
  def change
    remove_index :disputes, :domain_id
    add_index :disputes, :domain_id, unique: true
  end
end
