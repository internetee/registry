class AddIndexForContactCode < ActiveRecord::Migration
  def change
    add_index :contacts, :code
  end
end
