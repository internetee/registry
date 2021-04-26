class AddLogMatchingColumn < ActiveRecord::Migration[6.0]

  def change
    
    ApiLog::EppLog.connection.execute("ALTER TABLE epp_logs ADD COLUMN uuid varchar;")
    ApiLog::ReppLog.connection.execute("ALTER TABLE repp_logs ADD COLUMN uuid varchar;")

  end
end
