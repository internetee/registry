class NameAndPasswordForBlockedDomain < ActiveRecord::Migration
  def up
    add_column :blocked_domains, :name, :string
    add_index  :blocked_domains, :name

    BlockedDomain.find_each do |x, domain|
      names = domain.names
      domain.update_columns(name: names[x])
    end

    remove_column :blocked_domains, :names
  end

  def down

  end
end
