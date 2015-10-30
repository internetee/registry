module Legacy
  class Dnskey < Db
    self.table_name = :dnskey

    belongs_to :object_registry, foreign_key: :id
    belongs_to :object, foreign_key: :id
  end
end
