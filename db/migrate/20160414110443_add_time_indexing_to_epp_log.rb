class AddTimeIndexingToEppLog < ActiveRecord::Migration
  def change
    ApiLog::EppLog.connection.execute( "CREATE INDEX CONCURRENTLY epp_logs_created_at  ON epp_logs  USING btree (extract(epoch from created_at));")
    ApiLog::ReppLog.connection.execute("CREATE INDEX CONCURRENTLY repp_logs_created_at ON repp_logs USING btree (extract(epoch from created_at));")
  end
end
