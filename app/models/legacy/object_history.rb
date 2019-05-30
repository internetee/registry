module Legacy
  class ObjectHistory < Db
    self.table_name = :object_history

    belongs_to :object_registry, foreign_key: :historyid

    def self.instance_method_already_implemented?(method_name)
      return true if method_name == 'update'

      super
    end
  end
end
