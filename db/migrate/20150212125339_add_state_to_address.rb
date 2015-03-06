class AddStateToAddress < ActiveRecord::Migration
  def change
    add_column :addresses, :state, :string
  end
end
