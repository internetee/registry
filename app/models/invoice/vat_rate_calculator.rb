class Invoice
  class VatRateCalculator
    attr_reader :registry, :registrar

    def initialize(registry: Registry.current, registrar:)
      @registry = registry
      @registrar = registrar
    end

    def calculate
      if registrar.vat_liable_locally?(registry)
        registry.vat_rate
      else
        registrar.vat_rate || 0
      end
    end
  end
end
