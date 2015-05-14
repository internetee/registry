class RegistrantUser < User
  attr_accessor :idc_data

  def ability
    @ability ||= Ability.new(self)
  end
  delegate :can?, :cannot?, to: :ability

  def to_s
    registrant_ident
  end

  class << self
    def find_or_create_by_idc_data(idc_data)
      return false if idc_data.blank?
      identity_code = idc_data.scan(/serialNumber=(\d+)/).flatten.first
      country = idc_data.scan(/^\/C=(.{2})/).flatten.first

      where(registrant_ident: "#{country}-#{identity_code}").first_or_create
    end
  end
end
