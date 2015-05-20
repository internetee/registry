class AddRegistrarIdToEppSession < ActiveRecord::Migration
  def change
    add_column :epp_sessions, :registrar_id, :integer
  end
end
