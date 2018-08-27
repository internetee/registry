class RegistrantUser < User
  ACCEPTED_ISSUER = 'AS Sertifitseerimiskeskus'.freeze
  attr_accessor :idc_data

  devise :database_authenticatable, :trackable, :timeoutable

  def ability
    @ability ||= Ability.new(self)
  end
  delegate :can?, :cannot?, to: :ability

  def ident
    registrant_ident.to_s.split('-').last
  end

  def country_code
    registrant_ident.to_s.split('-').first
  end

  def domains
    Domain.uniq
          .joins(:contacts)
          .where(contacts: { ident_type: 'priv', ident: ident, ident_country_code: country_code })
  end

  def contacts
    Contact.where(ident_type: 'priv', ident: ident, ident_country_code: country_code)
  end

  # In Rails 5, can be replaced with a much simpler `or` query method and the raw SQL parts can be
  # removed.
  # https://guides.rubyonrails.org/active_record_querying.html#or-conditions
  def administered_domains
    domains_where_is_administrative_contact = begin
      Domain.joins(:domain_contacts)
            .where(domain_contacts: { contact_id: contacts, type: [AdminDomainContact] })
    end

    domains_where_is_registrar = Domain.where(registrant_id: contacts)

    Domain.from(
      "(#{domains_where_is_registrar.to_sql} UNION " \
      "#{domains_where_is_administrative_contact.to_sql}) AS domains"
    )
  end

  def to_s
    username
  end

  class << self
    def find_or_create_by_idc_data(idc_data, issuer_organization)
      return false if idc_data.blank?
      return false if issuer_organization != ACCEPTED_ISSUER

      idc_data.force_encoding('UTF-8')
      user_data = {}

      # handling here new and old mode
      if idc_data.starts_with?('/')
        user_data[:ident] = idc_data.scan(/serialNumber=(\d+)/).flatten.first
        user_data[:country_code] = idc_data.scan(/^\/C=(.{2})/).flatten.first
        user_data[:first_name] = idc_data.scan(%r{/GN=(.+)/serialNumber}).flatten.first
        user_data[:last_name] = idc_data.scan(%r{/SN=(.+)/GN}).flatten.first
      else
        parse_str = ',' + idc_data
        user_data[:ident] = parse_str.scan(/,serialNumber=(\d+)/).flatten.first
        user_data[:country_code] = parse_str.scan(/,C=(.{2})/).flatten.first
        user_data[:first_name] = parse_str.scan(/,GN=([^,]+)/).flatten.first
        user_data[:last_name] = parse_str.scan(/,SN=([^,]+)/).flatten.first
      end

      find_or_create_by_user_data(user_data)
    end

    def find_or_create_by_api_data(user_data = {})
      return false unless user_data[:ident]
      return false unless user_data[:first_name]
      return false unless user_data[:last_name]

      user_data.each_value { |v| v.upcase! if v.is_a?(String) }
      user_data[:country_code] ||= 'EE'

      find_or_create_by_user_data(user_data)
    end

    def find_or_create_by_mid_data(response)
      user_data = { first_name: response.user_givenname, last_name: response.user_surname,
                    ident: response.user_id_code, country_code: response.user_country }

      find_or_create_by_user_data(user_data)
    end

    private

    def find_or_create_by_user_data(user_data = {})
      return unless user_data[:first_name]
      return unless user_data[:last_name]
      return unless user_data[:ident]
      return unless user_data[:country_code]

      user = find_or_create_by(registrant_ident: "#{user_data[:country_code]}-#{user_data[:ident]}")
      user.username = "#{user_data[:first_name]} #{user_data[:last_name]}"
      user.save

      user
    end
  end
end
