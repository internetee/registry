module Legacy
  class Contact < Db
    self.table_name = :contact
    belongs_to :object_registry, foreign_key: :id
    belongs_to :object, foreign_key: :id
  end
end
