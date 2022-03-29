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

  def do_need_update_contacts?
    counter = 0

    counter += Contact.with_different_registrant_name(self).size

    companies.each do |company|
      counter += Contact.with_different_company_name(company).size
    end

    return { result: true, counter: counter } if counter.positive?

    { result: false, counter: 0 }
  end

  def update_contacts
    user = self
    contacts = []
    contacts.concat(Contact.with_different_registrant_name(user).each do |c|
      c.write_attribute(:name, user.username)
    end)
    companies.each do |company|
      contacts.concat(Contact.with_different_company_name(company).each do |c| 
        c.write_attribute(:name, company.company_name)
      end)
    end

    return [] if contacts.blank?

    group_and_bulk_update(contacts)

    contacts
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
      user
    end
  end

  private

  def group_and_bulk_update(contacts)
    grouped_contacts = contacts.group_by(&:registrar_id)
    grouped_contacts.each do |registrar_id, reg_contacts|
      bulk_action, action = actions.create!(operation: :bulk_update) if reg_contacts.size > 1
      reg_contacts.each do |c|
        if c.save(validate: false)
          action = actions.create!(contact: c, operation: :update, bulk_action_id: bulk_action&.id)
        end
      end
      notify_registrar_contacts_updated(action: bulk_action || action,
                                        registrar_id: registrar_id)
    end
  end

  def notify_registrar_contacts_updated(action:, registrar_id:)
    registrar = Registrar.find(registrar_id)
    registrar&.notify(action)
  end
end
