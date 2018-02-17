class AddEppSessionsSessionIdUniqueConstraint < ActiveRecord::Migration
  def up
    execute <<-SQL
      ALTER TABLE epp_sessions ADD CONSTRAINT unique_session_id UNIQUE (session_id)
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE epp_sessions DROP CONSTRAINT unique_session_id
    SQL
  end
end
