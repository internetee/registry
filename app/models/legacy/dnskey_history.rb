module Legacy
  class DnskeyHistory < Db
    self.table_name = :dnskey_history

    belongs_to :object_registry, foreign_key: :id
    belongs_to :object, foreign_key: :id
  end
end
