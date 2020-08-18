module PaymentOrders
  class Seb < BankLink
    def self.config_namespace_name
      'seb'
    end
  end
end
