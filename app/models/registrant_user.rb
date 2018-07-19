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
    ident_cc, ident = registrant_ident.to_s.split '-'
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

      # handling here new and old mode
      if idc_data.starts_with?("/")
        identity_code = idc_data.scan(/serialNumber=(\d+)/).flatten.first
        country       = idc_data.scan(/^\/C=(.{2})/).flatten.first
        first_name    = idc_data.scan(%r{/GN=(.+)/serialNumber}).flatten.first
        last_name     = idc_data.scan(%r{/SN=(.+)/GN}).flatten.first
      else
        parse_str = "," + idc_data
        identity_code = parse_str.scan(/,serialNumber=(\d+)/).flatten.first
        country       = parse_str.scan(/,C=(.{2})/).flatten.first
        first_name    = parse_str.scan(/,GN=([^,]+)/).flatten.first
        last_name     = parse_str.scan(/,SN=([^,]+)/).flatten.first
      end

      u = where(registrant_ident: "#{country}-#{identity_code}").first_or_create
      u.username = "#{first_name} #{last_name}"
      u.save

      u
    end

    def find_or_create_by_api_data(api_data = {})
      return false unless api_data[:ident]
      return false unless api_data[:first_name]
      return false unless api_data[:last_name]

      estonian_ident = "EE-#{api_data[:ident]}"

      user = find_or_create_by(registrant_ident: estonian_ident)
      user.username = "#{api_data[:first_name]} #{api_data[:last_name]}"
      user.save

      user
    end

    def find_or_create_by_mid_data(response)
      u = where(registrant_ident: "#{response.user_country}-#{response.user_id_code}").first_or_create
      u.username = "#{response.user_givenname} #{response.user_surname}"
      u.save

      u
    end
  end
end
