class RegistrantUser < User
  attr_accessor :idc_data

  devise :trackable, :timeoutable

  def ability
    @ability ||= Ability.new(self)
  end
  delegate :can?, :cannot?, to: :ability

  def ident
    registrant_ident.to_s[3..]
  end

  def country
    alpha2_code = registrant_ident.to_s.split('-').first
    Country.new(alpha2_code)
  end

  def companies(company_register = CompanyRegister::Client.new)
    return [] if ident.include?('-')

    company_register.representation_rights(citizen_personal_code: ident,
                                           citizen_country_code: country.alpha3)
  rescue CompanyRegister::NotAvailableError
    []
  end

  def do_need_update_contact?
    return { result: false, counter: 0 } if companies.blank?

    counter = 0
    companies.each do |company|
      counter += Contact.where(ident: company.registration_number, ident_country_code: 'EE')&.
                  reject { |contact| contact.name == company.company_name }.size
    end

    return { result: true, counter: counter } if counter.positive?

    { result: false, counter: 0 }
  end

  def update_company_contacts
    return [] if companies.blank?

    companies.each do |company|
      contacts = Contact.where(ident: company.registration_number, ident_country_code: 'EE')

      next if contacts.blank?

      contacts.each do |contact|
        next if company.company_name == contact.name

        update_company_name(contact: contact, company: company)
      end
    end

    companies
  end

  def update_company_name(contact:, company:)
    old_contact_name = contact.name
    contact.name = company.company_name

    contact.save(validate: false)

    notify_registrar_data_updated(company_name: company.company_name,
                                  old_contact_name: old_contact_name,
                                  contact: contact)
  end

  def notify_registrar_data_updated(company_name:, old_contact_name:, contact:)
    contact.registrar.notifications.create!(
      text: "Contact update: #{contact.id} name updated from #{old_contact_name} to #{company_name} by the registry"
    )
  end

  def contacts(representable: true)
    Contact.registrant_user_contacts(self, representable: representable)
  end

  def direct_contacts
    Contact.registrant_user_direct_contacts(self)
  end

  def domains(admin: false)
    return Domain.registrant_user_admin_registrant_domains(self) if admin

    Domain.registrant_user_domains(self)
  end

  def direct_domains(admin: false)
    return Domain.registrant_user_direct_admin_registrant_domains(self) if admin

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
    contacts = Contact.where(ident: ident, ident_country_code: country.alpha2)
                      .where('UPPER(name) != UPPER(?)', username)

    contacts.each do |contact|
      contact.update(name: username)
      action = actions.create!(contact: contact, operation: :update)
      contact.registrar.notify(action)
    end
  end

  class << self
    def find_or_create_by_api_data(user_data = {})
      return false unless user_data[:ident]
      return false unless user_data[:first_name]
      return false unless user_data[:last_name]

      user_data[:country_code] ||= 'EE'
      user_data[:country_code].upcase! if user_data[:country_code].is_a?(String)

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

      user.update_related_contacts
      user
    end
  end
end
