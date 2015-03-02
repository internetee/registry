module Legacy
  class ObjectRegistry < Db
    self.table_name = :object_registry
    self.inheritance_column = nil
    belongs_to :registrar, foreign_key: :crid, primary_key: :legacy_id, class_name: '::Registrar'
  end
end
