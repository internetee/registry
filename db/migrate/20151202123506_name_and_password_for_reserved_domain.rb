class NameAndPasswordForReservedDomain < ActiveRecord::Migration
  def up
    add_column :reserved_domains, :name, :string
    add_column :reserved_domains, :password, :string

    ReservedDomain.find_each do |domain|
      names = domain.names
      domain.update_columns(name: names.keys.first, password: names.values.first)
    end

    remove_column :reserved_domains, :names
  end

  def down

  end
end
