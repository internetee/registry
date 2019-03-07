class Registry
  include ActiveModel::Model

  attr_accessor :vat_rate
  attr_accessor :vat_country

  def self.current
    vat_rate = Setting.registry_vat_prc.to_d * 100
    vat_country = Country.new(Setting.registry_country_code)

    new(vat_rate: vat_rate, vat_country: vat_country)
  end
end