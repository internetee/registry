class AddRegistrarIdToEppSession < ActiveRecord::Migration[6.0]
  def change
    add_column :epp_sessions, :registrar_id, :integer
  end
end
