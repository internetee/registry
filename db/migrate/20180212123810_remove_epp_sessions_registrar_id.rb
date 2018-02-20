class RemoveEppSessionsRegistrarId < ActiveRecord::Migration
  def change
    remove_column :epp_sessions, :registrar_id, :integer
  end
end
