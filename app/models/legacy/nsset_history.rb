module Legacy
  class NssetHistory < Db
    self.table_name = :nsset_history
    self.primary_key = :id

    belongs_to :object, foreign_key: :id
    belongs_to :object_registry, foreign_key: :id
    belongs_to :history, foreign_key: :historyid, primary_key: :id
    has_many :hosts, foreign_key: :nssetid
    has_many :host_histories, foreign_key: :nssetid, primary_key: :id

    def self.at(time)
      joins(:history).where("(valid_from is null or valid_from <= '#{time.to_s}'::TIMESTAMPTZ)
            AND (valid_to is null or valid_to >= '#{time}'::TIMESTAMPTZ)")
    end
  end
end
