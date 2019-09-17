class DropKeyrelays < ActiveRecord::Migration
  def change
    drop_table :keyrelays
    drop_table :log_keyrelays
  end
end
