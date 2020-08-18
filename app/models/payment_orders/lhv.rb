module PaymentOrders
  class Lhv < BankLink
    def self.config_namespace_name
      'lhv'
    end
  end
end
