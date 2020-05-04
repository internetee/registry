module PaymentOrders
  class SystemPayment < PaymentOrder
    CONFIG_NAMESPACE = 'system_payment'.freeze

    def self.config_namespace_name
      CONFIG_NAMESPACE
    end
  end
end
