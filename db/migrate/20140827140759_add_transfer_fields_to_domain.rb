class AddTransferFieldsToDomain < ActiveRecord::Migration
  def change
    add_column :domains, :transferred_at, :datetime
    add_column :domains, :transfer_requested_at, :datetime
    add_column :domains, :transfer_to, :integer
  end
end
