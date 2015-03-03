module Legacy
  class ObjectState < Db
    self.table_name = :object_state

    belongs_to :enum_object_state, foreign_key: :state_id

    delegate :name, to: :enum_object_state, prefix: false, allow_nil: true
  end
end
