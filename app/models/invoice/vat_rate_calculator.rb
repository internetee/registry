class Invoice
  class VatRateCalculator
    OLD_VAT_RATE = 20.0

    attr_reader :registry, :registrar, :current_year

    def initialize(registry: Registry.current, current_year: Time.zone.today.year, registrar:)
      @registry = registry
      @registrar = registrar
      @current_year = current_year
    end

    def calculate
      if registrar.vat_liable_locally?(registry)
        current_year > 2023 ? registry.vat_rate : OLD_VAT_RATE  
      else
        registrar.vat_rate || 0
      end
    end
  end
end
