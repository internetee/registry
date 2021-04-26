class AddStateToAddress < ActiveRecord::Migration[6.0]
  def change
    add_column :addresses, :state, :string
  end
end
