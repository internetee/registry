class RenameReleasedDomainsToDomainNames < ActiveRecord::Migration
  def change
    rename_table :released_domains, :domain_names
  end
end
