class AddStatusesToDomain < ActiveRecord::Migration
  def change
    add_column :domains, :statuses, :string, array: true
  end
end
