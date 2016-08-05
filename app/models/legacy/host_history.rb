module Legacy
  class HostHistory < Db
    self.table_name = :host_history
    self.primary_key = :id

    belongs_to :history, foreign_key: :historyid
    has_many :host_ipaddr_maps, foreign_key: :hostid
    has_many :host_ipaddr_map_histories,  foreign_key: :hostid, primary_key: :id

    def self.at(time)
      joins(:history).where("(valid_from is null or valid_from <= '#{time.to_s}'::TIMESTAMPTZ)
            AND (valid_to is null or valid_to >= '#{time}'::TIMESTAMPTZ)")
    end
  end
end
