module Legacy
  class Object < Db
    self.table_name = :object
    belongs_to :registrar, foreign_key: :upid, primary_key: :legacy_id, class_name: '::Registrar'

    def self.instance_method_already_implemented?(method_name)
      return true if method_name == 'update'

      super
    end
  end
end
