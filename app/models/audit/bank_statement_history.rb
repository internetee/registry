module Audit
  class BankStatementHistory < BaseHistory
    self.table_name = 'audit.bank_statements'
  end
end
