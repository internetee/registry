class ChangeEppSessionsUserIdToNotNull < ActiveRecord::Migration[6.0]
  def change
    change_column_null :epp_sessions, :user_id, false
  end
end
