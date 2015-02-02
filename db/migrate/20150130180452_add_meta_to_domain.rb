class AddMetaToDomain < ActiveRecord::Migration
  def change
    rename_column :log_domains, :nameserver_version_ids, :nameserver_ids
    add_column    :log_domains,   :tech_contact_ids, :text, array: true, default: []
    add_column    :log_domains,   :admin_contact_ids, :text, array: true, default: []
  end
end
