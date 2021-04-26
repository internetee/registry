class RenameReleasedDomainsToDomainNames < ActiveRecord::Migration[6.0]
  def change
    rename_table :released_domains, :domain_names
  end
end
