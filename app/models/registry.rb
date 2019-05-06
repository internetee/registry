class Registry
  include Singleton

  def vat_rate
    Setting.registry_vat_prc.to_d * 100
  end

  def legal_address_country
    Country.new(Setting.registry_country_code)
  end

  def billing_address
    address
  end

  private

  def address
    Address.new(street: Setting.registry_street,
                zip: Setting.registry_zip,
                city: Setting.registry_city,
                state: Setting.registry_state,
                country: Country.new(Setting.registry_country_code))
  end
end
