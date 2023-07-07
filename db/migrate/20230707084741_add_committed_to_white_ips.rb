class AddCommittedToWhiteIps < ActiveRecord::Migration[6.1]
  def change
    add_column :white_ips, :committed, :boolean, default: true
  end
end
