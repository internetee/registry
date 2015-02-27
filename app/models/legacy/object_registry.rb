module Legacy
  class ObjectRegistry < Db
    self.table_name = :object_registry
    self.inheritance_column = nil
  end
end
