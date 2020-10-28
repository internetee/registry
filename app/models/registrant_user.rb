class RegistrantUser < User
  attr_accessor :idc_data

  devise :trackable, :timeoutable
  after_save :update_related_contacts

  def ability
    @ability ||= Ability.new(self)
  end
  delegate :can?, :cannot?, to: :ability

  def ident
    registrant_ident.to_s.split('-').last
  end

  def country
    alpha2_code = registrant_ident.to_s.split('-').first
    Country.new(alpha2_code)
  end

  def companies(company_register = CompanyRegister::Client.new)
    company_register.representation_rights(citizen_personal_code: ident,
                                           citizen_country_code: country.alpha3)
  end

  def contacts(representable: true)
    Contact.registrant_user_contacts(self, representable: representable)
  end

  def direct_contacts
    Contact.registrant_user_direct_contacts(self)
  end

  def domains
    Domain.registrant_user_domains(self)
  end

  def direct_domains
    Domain.registrant_user_direct_domains(self)
  end

  def administered_domains
    Domain.registrant_user_administered_domains(self)
  end

  def to_s
    username
  end

  def first_name
    username.split.first
  end

  def last_name
    username.split.second
  end

  def update_related_contacts
    cc, idcode = registrant_ident.split('-')
    contacts = Contact.where(ident: idcode, country_code: cc).where('name != ?', username)
    contacts.each { |c| c.update(name: username) }
  end

  class << self
    def find_or_create_by_api_data(user_data = {})
      return false unless user_data[:ident]
      return false unless user_data[:first_name]
      return false unless user_data[:last_name]

      user_data.each_value { |v| v.upcase! if v.is_a?(String) }
      user_data[:country_code] ||= 'EE'

      find_or_create_by_user_data(user_data)
    end

    def find_or_create_by_omniauth_data(omniauth_hash)
      uid = omniauth_hash['uid']
      identity_code = uid.slice(2..-1)
      country_code = uid.slice(0..1)
      first_name = omniauth_hash.dig('info', 'first_name')
      last_name = omniauth_hash.dig('info', 'last_name')

      user_data = { first_name: first_name, last_name: last_name,
                    ident: identity_code, country_code: country_code }

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
