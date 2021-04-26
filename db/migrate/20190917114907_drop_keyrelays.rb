class DropKeyrelays < ActiveRecord::Migration[6.0]
  def change
    drop_table :keyrelays
    drop_table :log_keyrelays
  end
end
