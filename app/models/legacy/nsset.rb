module Legacy
  class Nsset < Db
    self.table_name = :nsset

    belongs_to :object, foreign_key: :id
    belongs_to :object_registry, foreign_key: :id
    has_many :hosts, foreign_key: :nssetid
  end
end
