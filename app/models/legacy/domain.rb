module Legacy
  class Domain < Db
    self.table_name = :domain

    belongs_to :object_registry, foreign_key: :id
    belongs_to :object, foreign_key: :id
    belongs_to :object_state, foreign_key: :id, primary_key: :object_id
    belongs_to :registrant, foreign_key: :registrant, primary_key: :legacy_id, class_name: '::Contact'
  end
end
