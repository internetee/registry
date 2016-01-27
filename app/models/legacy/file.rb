module Legacy
  class File < Db
    self.table_name = :files

    def self.for_history history_id
      history_ids = Array(history_id)
      sql = %Q{select history.id, files.path, files.name, files.crdate
              from history
                join action ON action.id=history.action
                join files on action.servertrid=files.servertrid
              where history.id IN (#{history_ids.join(",")});}
      find_by_sql(sql).to_a
    end
  end
end