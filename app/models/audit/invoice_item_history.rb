module Audit
  class InvoiceItemHistory < BaseHistory
    self.table_name = 'audit.invoice_items'
  end
end
