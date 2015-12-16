module Legacy
  class Dnskey < Db
    self.table_name = :dnskey
    self.primary_key = :id

    belongs_to :object_registry, foreign_key: :id
    belongs_to :object, foreign_key: :id
    has_one :object_history, foreign_key: :historyid, primary_key: :historyid
  end
end
