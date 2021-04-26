class AddEppSessionsUserId < ActiveRecord::Migration[6.0]
  def change
    add_reference :epp_sessions, :user, foreign_key: true
  end
end
