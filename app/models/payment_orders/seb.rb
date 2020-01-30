module PaymentOrders
  class SEB < BankLink
    def self.config_namespace_name
      'seb'
    end
  end
end
