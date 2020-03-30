module Audit
  class BankTransaction < Base
    self.table_name = 'audit.bank_transactions'
  end
end
