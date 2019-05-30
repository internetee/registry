module Legacy
  class Registrar < Db
    self.table_name = :registrar

    has_many :invoices, foreign_key: :registrarid
    has_many :acl, foreign_key: :registrarid, class_name: 'Legacy::RegistrarAcl'

    def account_balance
      invoices.sum(:credit)
    end
  end
end
