module Audit
  class BankTransactionHistory < BaseHistory
    self.table_name = 'audit.bank_transactions'
  end
end
