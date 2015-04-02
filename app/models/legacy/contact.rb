module Legacy
  class Contact < Db
    self.table_name = :contact
    belongs_to :object_registry, foreign_key: :id
    belongs_to :object, foreign_key: :id
    belongs_to :object_state, foreign_key: :id, primary_key: :object_id
  end
end
