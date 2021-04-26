class RemoveEppSessionsRegistrarId < ActiveRecord::Migration[6.0]
  def change
    remove_column :epp_sessions, :registrar_id, :integer
  end
end
