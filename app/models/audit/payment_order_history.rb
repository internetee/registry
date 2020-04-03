module Audit
  class PaymentOrderHistory < BaseHistory
    self.table_name = 'audit.payment_orders'
  end
end
