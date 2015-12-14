class RegistrantUser < User
  ACCEPTED_ISSUER = 'AS Sertifitseerimiskeskus'
  attr_accessor :idc_data

  def ability
    @ability ||= Ability.new(self)
  end
  delegate :can?, :cannot?, to: :ability

  def ident
    registrant_ident.to_s.split("-").last
  end

  def domains
    # TODO: move data to normal columns and drop registrant_ident
    ident_cc, ident = @current_user.registrant_ident.split '-'
    Domain.includes(:registrar, :registrant).where(contacts: {
                                                       ident_type: 'priv',
                                                       ident: ident, #identity_code,
                                                       ident_country_code: ident_cc #country_code
                                                   })
  end

  def to_s
    username
  end

  class << self
    def find_or_create_by_idc_data(idc_data, issuer_organization)
      return false if idc_data.blank?
      return false if issuer_organization != ACCEPTED_ISSUER

      idc_data.force_encoding('UTF-8')
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
