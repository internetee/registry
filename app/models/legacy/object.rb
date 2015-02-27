module Legacy
  class Object < Db
    self.table_name = :object

    def self.instance_method_already_implemented?(method_name)
      return true if method_name == 'update'
      super
    end
  end
end
