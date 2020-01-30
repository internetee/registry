module PaymentOrders
  class LHV < BankLink
    def self.config_namespace_name
      'lhv'
    end
  end
end
