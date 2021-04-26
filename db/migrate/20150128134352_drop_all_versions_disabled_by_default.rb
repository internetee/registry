class DropAllVersionsDisabledByDefault < ActiveRecord::Migration[6.0]
  def change
    # All versions are depricated by log_* tables

    # comment to remove unneeded old versions tables 
    # drop_table "version_associations"
    # drop_table "versions"
    # drop_table "address_versions"
    # drop_table "contact_versions"
    # drop_table "domain_status_versions"
    # drop_table "domain_versions"
    # drop_table "nameserver_versions"
  end
end
