class AddUpdatedAtToDnskey < ActiveRecord::Migration
  def change
    add_column :dnskeys, :updated_at, :datetime
  end
end
