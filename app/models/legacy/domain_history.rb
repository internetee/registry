module Legacy
  class DomainHistory < Db
    self.table_name = :domain_history

    belongs_to :domain, foreign_key: :id
  end
end
