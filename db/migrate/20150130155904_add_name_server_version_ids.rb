class AddNameServerVersionIds < ActiveRecord::Migration
  def change
    add_column :log_domains, :nameserver_version_ids, :text, array: true, default: []
  end
end
