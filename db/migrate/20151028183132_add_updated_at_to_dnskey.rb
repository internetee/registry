class AddUpdatedAtToDnskey < ActiveRecord::Migration[6.0]
  def change
    add_column :dnskeys, :updated_at, :datetime
  end
end
