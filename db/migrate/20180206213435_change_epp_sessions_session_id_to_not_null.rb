class ChangeEppSessionsSessionIdToNotNull < ActiveRecord::Migration[6.0]
  def change
    change_column_null :epp_sessions, :session_id, false
  end
end
