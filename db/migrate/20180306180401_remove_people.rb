class RemovePeople < ActiveRecord::Migration[6.0]
  def change
    drop_table :people
  end
end
