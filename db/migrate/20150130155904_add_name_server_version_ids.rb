class AddNameServerVersionIds < ActiveRecord::Migration[6.0]
  def change
    add_column :log_domains, :nameserver_version_ids, :text, array: true, default: []
  end
end
