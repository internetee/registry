class AddEppSessionsUserId < ActiveRecord::Migration
  def change
    add_reference :epp_sessions, :user, foreign_key: true
  end
end
