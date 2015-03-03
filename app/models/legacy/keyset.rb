module Legacy
  class Keyset < Db
    self.table_name = :keyset

    has_many :dsrecords, foreign_key: :keysetid
  end
end
