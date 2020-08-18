module PaymentOrders
  class Swed < BankLink
    def self.config_namespace_name
      'swed'
    end
  end
end
