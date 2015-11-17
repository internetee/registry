module Legacy
  class DomainHistory < Db
    self.table_name = :domain_history

    belongs_to :domain, foreign_key: :id
    belongs_to :history, foreign_key: :historyid
    has_one :object_history, foreign_key: :historyid, primary_key: :historyid
  end
end
