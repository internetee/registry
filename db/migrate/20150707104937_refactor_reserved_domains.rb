class RefactorReservedDomains < ActiveRecord::Migration[6.0]
  def change
    remove_column :reserved_domains, :name
    add_column :reserved_domains, :names, :hstore
  end
end
