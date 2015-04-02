module Legacy
  class Nsset < Db
    self.table_name = :nsset

    has_many :hosts, foreign_key: :nssetid
  end
end
