module Legacy
  class Contact < Db
    self.table_name = :contact
    belongs_to :object_registry, foreign_key: :id
    belongs_to :object, foreign_key: :id

    has_one :object_state, -> { where('valid_to IS NULL') }, foreign_key: :object_id
  end
end
