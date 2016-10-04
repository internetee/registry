class AdduuidIndexToEppLogs < ActiveRecord::Migration
    def change
      ApiLog::EppLog.connection.execute( "CREATE INDEX CONCURRENTLY epp_logs_uuid  ON epp_logs  USING btree uuid;")
      ApiLog::ReppLog.connection.execute( "CREATE INDEX CONCURRENTLY repp_logs_uuid  ON repp_logs  USING btree uuid;")
   end
end

