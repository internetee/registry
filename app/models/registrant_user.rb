class RegistrantUser < User
  attr_accessor :idc_data

  def ability
    @ability ||= Ability.new(self)
  end
  delegate :can?, :cannot?, to: :ability

  def to_s
    username
  end

  class << self
    def find_or_create_by_idc_data(idc_data, issuer_organization)
      return false if idc_data.blank?
      return false if issuer_organization != 'AS Sertifitseerimiskeskus'

      idc_data.force_encoding('UTF-8')
      logger.error(idc_data)
      logger.error(idc_data.encoding)
      identity_code = idc_data.scan(/serialNumber=(\d+)/).flatten.first
      country = idc_data.scan(/^\/C=(.{2})/).flatten.first
      first_name = idc_data.scan(%r{/GN=(.+)/serialNumber}).flatten.first
      last_name = idc_data.scan(%r{/SN=(.+)/GN}).flatten.first

      u = where(registrant_ident: "#{country}-#{identity_code}").first_or_create
      u.username = "#{first_name} #{last_name}"
      u.save

      u
    end

    def find_or_create_by_mid_data(response)
      u = where(registrant_ident: "#{response.user_country}-#{response.user_id_code}").first_or_create
      u.username = "#{response.user_givenname} #{response.user_surname}"
      u.save

      u
    end
  end
end
