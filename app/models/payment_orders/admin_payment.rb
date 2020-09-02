module PaymentOrders
  class AdminPayment < PaymentOrder
    CONFIG_NAMESPACE = 'admin_payment'.freeze

    def self.config_namespace_name
      CONFIG_NAMESPACE
    end
  end
end
