class RemoveEppSessionsSessionIdUniqueIndex < ActiveRecord::Migration
  def change
    remove_index :epp_sessions, name: :index_epp_sessions_on_session_id
  end
end
