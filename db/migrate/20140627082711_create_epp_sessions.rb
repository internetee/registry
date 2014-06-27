class CreateEppSessions < ActiveRecord::Migration
  def change
    create_table :epp_sessions do |t|
      t.string :session_id
      t.text :data
      t.timestamps
    end

    add_index :epp_sessions, :session_id, :unique => true
    add_index :epp_sessions, :updated_at
  end
end
