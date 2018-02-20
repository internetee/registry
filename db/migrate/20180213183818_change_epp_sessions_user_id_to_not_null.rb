class ChangeEppSessionsUserIdToNotNull < ActiveRecord::Migration
  def change
    change_column_null :epp_sessions, :user_id, false
  end
end
