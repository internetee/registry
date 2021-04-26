class AddStatusesToDomain < ActiveRecord::Migration[6.0]
  def change
    add_column :domains, :statuses, :string, array: true
  end
end
