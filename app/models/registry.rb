class Registry
  include Singleton

  def vat_rate
    Setting.registry_vat_prc.to_d * 100
  end

  def legal_address_country
    Country.new(Setting.registry_country_code)
  end
end
