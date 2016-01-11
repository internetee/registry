class NameAndPasswordForBlockedDomain < ActiveRecord::Migration
  def up
    add_column :blocked_domains, :name, :string
    add_index  :blocked_domains, :name
    remove_column :blocked_domains, :names
  end

  def down

  end
end
