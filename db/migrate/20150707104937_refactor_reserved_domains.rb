class RefactorReservedDomains < ActiveRecord::Migration
  def change
    remove_column :reserved_domains, :name
    add_column :reserved_domains, :names, :hstore
  end
end
