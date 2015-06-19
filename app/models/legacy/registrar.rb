module Legacy
  class Registrar < Db
    self.table_name = :registrar

    has_many :invoices, foreign_key: :registrarid

    def account_balance
      invoices.sum(:credit)
    end
  end
end
