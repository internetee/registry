class AddConstraintsPartIi < ActiveRecord::Migration
  def change
    change_column_null :white_ips, :registrar_id, false
    add_foreign_key :white_ips, :registrars
  end
end
