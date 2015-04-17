class InvoiceItemVersion < PaperTrail::Version
  self.table_name    = :log_invoice_items
  self.sequence_name = :log_invoice_items_id_seq
end
