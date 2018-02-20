class ChangeEppSessionsSessionIdToNotNull < ActiveRecord::Migration
  def change
    change_column_null :epp_sessions, :session_id, false
  end
end
