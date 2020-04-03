module Audit
  class InvoiceHistory < BaseHistory
    self.table_name = 'audit.invoices'
  end
end
