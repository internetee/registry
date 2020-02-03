class PaymentOrderVersion < PaperTrail::Version
  self.table_name    = :log_payment_orders
  self.sequence_name = :log_payment_orders_id_seq
end
