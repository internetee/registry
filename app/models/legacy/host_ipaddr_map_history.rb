module Legacy
  class HostIpaddrMapHistory < Db
    self.table_name = :host_ipaddr_map_history
    self.primary_key = :id
    belongs_to :history, foreign_key: :historyid

    def self.at(time)
      joins(:history).where("(valid_from is null or valid_from <= '#{time.to_s}'::TIMESTAMPTZ)
            AND (valid_to is null or valid_to >= '#{time}'::TIMESTAMPTZ)")
    end
  end
end
