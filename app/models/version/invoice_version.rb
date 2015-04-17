class InvoiceVersion < PaperTrail::Version
  self.table_name    = :log_invoices
  self.sequence_name = :log_invoices_id_seq
end
