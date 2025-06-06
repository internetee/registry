require 'deserializers/xml/legal_document'

class Contact < ApplicationRecord
  include Versions # version/contact_version.rb
  include Roids
  include EppErrors
  include UserEvents
  include Contact::Transferable
  include Contact::Identical
  include Contact::Archivable
  include Contact::CompanyRegister
  include EmailVerifable
  include AgeValidation

  belongs_to :original, class_name: 'Contact'
  belongs_to :registrar, required: true
  has_many :domain_contacts
  has_many :domains, through: :domain_contacts
  has_many :legal_documents, as: :documentable
  has_many :validation_events, as: :validation_eventable, dependent: :destroy
  has_many :registrant_domains, class_name: 'Domain', foreign_key: 'registrant_id'
  has_many :actions, dependent: :destroy

  attr_accessor :legal_document_id

  alias_attribute :kind, :ident_type
  alias_attribute :copy_from_id, :original_id # Old attribute name; for PaperTrail

  scope :email_verification_failed, lambda {
    joins('LEFT JOIN email_address_verifications emv ON contacts.email = emv.email')
      .where('success = false and verified_at IS NOT NULL')
  }

  scope :with_different_company_name, (lambda do |company|
    where("ident = ? AND ident_country_code = 'EE' AND name != ?",
          company.registration_number,
          company.company_name)
  end)

  scope :with_different_registrant_name, (lambda do |user|
    where('ident = ? AND ident_country_code = ? AND UPPER(name) != UPPER(?)',
          user.ident,
          user.country.alpha2,
          user.username)
  end)

  NAME_REGEXP = /([\u00A1-\u00B3\u00B5-\u00BF\u0021-\u0026\u0028-\u002C\u003A-\u0040]|
    [\u005B-\u005F\u007B-\u007E\u2040-\u206F\u20A0-\u20BF\u2100-\u218F])/x

  validates :name, :email, presence: true
  validates :name, length: { maximum: 255, message: :too_long_contact_name }
  validates :name, format: { without: NAME_REGEXP, message: :invalid }, if: -> { priv? }

  validates :street, :city, :zip, :country_code, presence: true, if: lambda {
    self.class.address_processing?
  }

  validates :phone, presence: true, e164: true, phone: true

  # validate :correct_email_format, if: proc { |c| c.will_save_change_to_email? }

  validates :code,
            uniqueness: { message: :epp_id_taken },
            format: { with: /\A[\w\-\:\.\_]*\z/i, message: :invalid },
            length: { maximum: 100, message: :too_long_contact_code }
  validates_associated :identifier

  validate :validate_html
  validate :validate_country_code, if: -> { self.class.address_processing? }
  validates :registrant_publishable, inclusion: { in: [true, false] }, if: -> { registrant? }
  # validates :registrant_publishable, inclusion: { in: [false] }, unless: -> { registrant? }

  after_initialize do
    self.status_notes = {} if status_notes.nil?
    self.ident_updated_at = Time.zone.now if new_record? && ident_updated_at.blank?
  end

  before_validation :to_upcase_country_code
  before_validation :strip_email

  composed_of :identifier,
              class_name: 'Contact::Ident',
              constructor: proc { |code, type, country_code| Contact::Ident.new(code: code,
                                                                                type: type,
                                                                                country_code: country_code) },
              mapping: [%w[ident code], %w[ident_type type], %w[ident_country_code country_code]]

  after_commit :update_related_whois_records
  before_validation :clear_address_modifications, if: -> { !self.class.address_processing? }

  # TODO: remove after testing
  after_save do
    Rails.logger.info "Contact saved or updated: #{id}"
  end

  self.ignored_columns = %w[legacy_id legacy_history_id]

  ORG = 'org'.freeze
  PRIV = 'priv'.freeze

  # For foreign private persons who has no national identification number
  BIRTHDAY = 'birthday'.freeze

  # From old registry software ("Fred"). No new contact can be created with this status
  PASSPORT = 'passport'.freeze

  #
  # STATUSES
  #
  # Requests to delete the object MUST be rejected.
  CLIENT_DELETE_PROHIBITED = 'clientDeleteProhibited'.freeze
  SERVER_DELETE_PROHIBITED = 'serverDeleteProhibited'.freeze

  # Requests to transfer the object MUST be rejected.
  CLIENT_TRANSFER_PROHIBITED = 'clientTransferProhibited'.freeze
  SERVER_TRANSFER_PROHIBITED = 'serverTransferProhibited'.freeze

  # The contact object has at least one active association with
  # another object, such as a domain object. Servers SHOULD provide
  # services to determine existing object associations.
  # "linked" status MAY be combined with any status.
  LINKED = 'linked'.freeze

  # This is the normal status value for an object that has no pending
  # operations or prohibitions. This value is set and removed by the
  # server as other status values are added or removed.
  # "ok" status MAY only be combined with "linked" status.
  OK = 'ok'.freeze

  # Requests to update the object (other than to remove this status) MUST be rejected.
  CLIENT_UPDATE_PROHIBITED = 'clientUpdateProhibited'.freeze
  SERVER_UPDATE_PROHIBITED = 'serverUpdateProhibited'.freeze

  # A transform command has been processed for the object, but the
  # action has not been completed by the server. Server operators can
  # delay action completion for a variety of reasons, such as to allow
  # for human review or third-party action. A transform command that
  # is processed, but whose requested action is pending, is noted with
  # response code 1001.
  # When the requested action has been completed, the pendingCreate,
  # pendingDelete, pendingTransfer, or pendingUpdate status value MUST be
  # removed.  All clients involved in the transaction MUST be notified
  # using a service message that the action has been completed and that
  # the status of the object has changed.
  # The pendingCreate, pendingDelete, pendingTransfer, and pendingUpdate
  # status values MUST NOT be combined with each other.
  PENDING_CREATE = 'pendingCreate'.freeze
  # "pendingTransfer" status MUST NOT be combined with either
  # "clientTransferProhibited" or "serverTransferProhibited" status.
  PENDING_TRANSFER = 'pendingTransfer'.freeze
  # "pendingUpdate" status MUST NOT be combined with either
  # "clientUpdateProhibited" or "serverUpdateProhibited" status.
  PENDING_UPDATE = 'pendingUpdate'.freeze
  # "pendingDelete" MUST NOT be combined with either
  # "clientDeleteProhibited" or "serverDeleteProhibited" status.
  PENDING_DELETE = 'pendingDelete'.freeze

  DISCLOSE_ATTRIBUTES = %w[
    name
    email
    phone
    registrant_publishable
    address
    fax
  ].freeze

  OPEN_LEGAL_ATTRIBUTES = %w[
    phone
  ].freeze

  STATUSES = [
    CLIENT_DELETE_PROHIBITED, SERVER_DELETE_PROHIBITED,
    CLIENT_TRANSFER_PROHIBITED,
    SERVER_TRANSFER_PROHIBITED, CLIENT_UPDATE_PROHIBITED, SERVER_UPDATE_PROHIBITED,
    OK, PENDING_CREATE, PENDING_DELETE, PENDING_TRANSFER,
    PENDING_UPDATE, LINKED
  ].freeze

  CLIENT_STATUSES = [
    CLIENT_DELETE_PROHIBITED, CLIENT_TRANSFER_PROHIBITED,
    CLIENT_UPDATE_PROHIBITED
  ].freeze

  SERVER_STATUSES = [
    SERVER_UPDATE_PROHIBITED,
    SERVER_DELETE_PROHIBITED,
    SERVER_TRANSFER_PROHIBITED,
  ].freeze
  #
  # END OF STATUSES
  #

  class << self
    def ransackable_associations(*)
      authorizable_ransackable_associations
    end

    def ransackable_attributes(*)
      authorizable_ransackable_attributes
    end

    def search_by_query(query)
      res = search(code_cont: query).result
      res.reduce([]) { |o, v| o << { id: v[:id], display_key: "#{v.name} (#{v.code})" } }
    end

    def filter_by_states in_states
      states = Array(in_states).dup
      scope  = all

      # all contacts has state ok, so no need to filter by it
      if states.delete(OK)
        scope = scope.where("NOT contacts.statuses && ?::varchar[]", "{#{(STATUSES - [OK, LINKED]).join(',')}}")
      end
      scope = scope.linked if states.delete(LINKED)
      scope = scope.where("contacts.statuses @> ?::varchar[]", "{#{states.join(',')}}") if states.any?
      scope
    end

    def admin_statuses
      [
        SERVER_UPDATE_PROHIBITED,
        SERVER_DELETE_PROHIBITED
      ]
    end

    def admin_statuses_map
      [
        ['UpdateProhibited', SERVER_UPDATE_PROHIBITED],
        ['DeleteProhibited', SERVER_DELETE_PROHIBITED]
      ]
    end

    def pdf(html)
      kit = PDFKit.new(html)
      kit.to_pdf
    end

    def emails
      pluck(:email)
    end

    def address_processing?
      Setting.address_processing
    end

    def address_attribute_names
      %w(
        city
        street
        zip
        country_code
        state
      )
    end

    def registrant_user_contacts(registrant_user, representable: true)
      represented_contacts = registrant_user_direct_contacts(registrant_user)
                             .or(registrant_user_company_contacts(registrant_user))

      return represented_contacts if representable

      represented_contacts.or(registrant_user_indirect_contacts(registrant_user))
    end

    def registrant_user_direct_contacts(registrant_user)
      where(ident_type: PRIV, ident: registrant_user.ident, ident_country_code: registrant_user
                                                                                  .country.alpha2)
    end

    def linked
      sql = <<-SQL
        EXISTS(SELECT 1 FROM domains WHERE domains.registrant_id = contacts.id) OR
        EXISTS(SELECT 1 FROM domain_contacts WHERE domain_contacts.contact_id =
        contacts.id)
      SQL

      where(sql)
    end

    def unlinked
      where('NOT EXISTS(SELECT 1 FROM domains WHERE domains.registrant_id = contacts.id)
             AND
             NOT EXISTS(SELECT 1 FROM domain_contacts WHERE domain_contacts.contact_id =
             contacts.id)')
    end

    def registrant_user_company_contacts(registrant_user)
      ident = registrant_user.companies.collect(&:registration_number)

      where(ident_type: ORG,
            ident: ident,
            ident_country_code: registrant_user.country.alpha2)
    end

    def registrant_user_indirect_contacts(registrant_user)
      company_domains = Domain.registrant_user_indirect_domains(registrant_user)
      company_contact_ids = company_domains.map(&:contacts).flatten.collect(&:id)
      company_ids = Contact.registrant_user_company_contacts(registrant_user).collect(&:id)
      total_ids = (company_contact_ids + company_ids).uniq

      where(id: total_ids)
    end
  end

  # kind of decorator in order to always return statuses
  # if we use separate decorator, then we should add it
  # to too many places
  def statuses
    calculated = Array(read_attribute(:statuses))
    calculated.delete(Contact::OK)
    calculated.delete(Contact::LINKED)
    calculated << Contact::OK     if calculated.empty?# && valid?
    calculated << Contact::LINKED if linked?

    calculated.uniq
  end

  def statuses= arr
    write_attribute(:statuses, Array(arr).uniq)
  end

  def to_s
    name
  end

  def validate_html
    self.class.columns.each do |column|
      next unless column.type == :string

      c_name = column.name
      val    = read_attribute(c_name)
      if val && (val.include?('<') || val.include?('>') || val.include?('%3C') || val.include?('%3E'))
        errors.add(c_name, :invalid)
        return # want to run code faster
      end
    end
  end

  def org?
    ident_type == ORG
  end

  # it might mean priv or birthday type
  def priv?
    !org?
  end

  def code=(code)
    self[:code] = code if new_record? # cannot change code later
  end

  def generate_code
    return nil unless new_record?
    return nil if registrar.blank?
    code = self[:code]

    # custom code from client
    # add prefix when needed
    if code.present?
      prefix, *custom_code = code.split(':')
      code = custom_code.join(':') if prefix == registrar.code
    end

    code = SecureRandom.hex(4) if code.blank? || code == registrar.code

    self[:code] = "#{registrar.code}:#{code}".upcase
  end

  alias_method :regenerate_code, :generate_code

  def country
    Country.new(country_code)
  end

  def to_upcase_country_code
    self.ident_country_code = ident_country_code.upcase if ident_country_code
    self.country_code       = country_code.upcase if country_code
  end

  def validate_country_code
    return unless country_code
    errors.add(:country_code, :invalid) unless Country.new(country_code)
  end

  def related_domain_descriptions
    @desc = {}

    registrant_domains.each do |dom|
      @desc[dom.name] ||= { id: dom.uuid, roles: [] }
      @desc[dom.name][:roles] << :registrant
    end

    domain_contacts.includes(:domain).each do |dc|
      @desc[dc.domain.name] ||= { id: dc.domain.uuid, roles: [] }
      @desc[dc.domain.name][:roles] << dc.name.downcase.to_sym
      @desc[dc.domain.name] = @desc[dc.domain.name].compact
    end

    @desc
  end

  # Limits returned objects to 11
  def related_domains
    ids = DomainContact.select(:domain_id).where(contact_id: id).limit(11).map(&:domain_id).uniq
    res = Domain.where(id: ids).or(Domain.where(registrant_id: id)).select(:name, :uuid).limit(11)
    res.pluck(:name, :uuid).map { |name, id| { name: name, id: id } }
  end

  def status_notes_array=(notes)
    self.status_notes = {}
    notes ||= []
    statuses.each_with_index do |status, i|
      status_notes[status] = notes[i]
    end
  end

  def search_name
    "#{code} #{name}"
  end

  def name_disclosed_by_registrar(reg_id)
    registrar_id == reg_id ? name : 'N/A'
  end

  def strip_email
    self.email = email.to_s.strip
  end

  # what we can do load firstly by registrant
  # if total is smaller than needed, the load more
  # we also need to sort by valid_to
  # todo: extract to drapper. Then we can remove Domain#roles
  def all_domains(page: nil, per: nil, params:, requester: nil)
    filter_sql = qualified_domain_ids(params[:domain_filter])

    # get sorting rules
    sorts = params.fetch(:sort, {}).first || []
    sort  = %w[name registrar_name valid_to].include?(sorts.first) ? sorts.first : 'valid_to'
    order = %w[asc desc].include?(sorts.second) ? sorts.second : 'desc'

    # fetch domains
    domains = qualified_domain_name_list(requester, filter_sql)
    domains = domains.includes(:registrar).page(page).per(per)

    # using small rails hack to generate outer join
    domains = if sorts.first == 'registrar_name'.freeze
                domains.where.not(registrars: { id: nil })
                       .order("registrars.name #{order} NULLS LAST")
              else
                domains.order("#{sort} #{order} NULLS LAST")
              end

    # adding roles. Need here to make faster sqls
    domain_c = Hash.new([])
    registrant_domains.where(id: domains.map(&:id)).each do |d|
      domain_c[d.id] |= ['Registrant'.freeze]
    end

    DomainContact.where(contact_id: id, domain_id: domains.map(&:id)).each do |d|
      domain_c[d.domain_id] |= [d.type]
    end

    domains.each { |d| d.roles = domain_c[d.id].uniq }
    domains
  end

  def qualified_domain_name_list(requester, filter_sql)
    return Domain.where('domains.id IN (?)', filter_sql) if requester.blank?

    registrant_user = RegistrantUser.find_or_initialize_by(registrant_ident:
      "#{requester.ident_country_code}-#{requester.ident}")
    begin
      registrant_user.domains.where('domains.id IN (?)', filter_sql)
    rescue CompanyRegister::NotAvailableError
      registrant_user.direct_domains.where('domains.id IN (?)', filter_sql)
    end
  end

  def qualified_domain_ids(filters)
    rant_domains = registrant_domains.map { |d| { id: d.id, type: ['Registrant'] } }
    contact_domains = domain_contacts.map { |dc| { id: dc.domain_id, type: [dc.type] } }
    grouped_domains = group_by_id_and_type(rant_domains + contact_domains)
    return grouped_domains.keys if filters.nil? || filters == ''

    # use domain_filters.sort == v.sort if should be exact match
    grouped_domains.reject { |_, v| ([].push(filters).flatten & v).empty? }.keys
  end

  # def qualified_domain_ids(domain_filter)
  #   registrant_ids = registrant_domains.pluck(:id)
  #   return registrant_ids if domain_filter == 'Registrant'

  #   if %w[AdminDomainContact TechDomainContact].include? domain_filter
  #     DomainContact.where(contact_id: id, type: domain_filter).pluck(:domain_id)
  #   else
  #     (DomainContact.where(contact_id: id).pluck(:domain_id) +
  #      registrant_ids).uniq
  #   end
  # end

  def update_prohibited?
    (statuses & [
      CLIENT_UPDATE_PROHIBITED,
      SERVER_UPDATE_PROHIBITED,
      CLIENT_TRANSFER_PROHIBITED,
      SERVER_TRANSFER_PROHIBITED,
      PENDING_CREATE,
      PENDING_TRANSFER,
      PENDING_UPDATE,
      PENDING_DELETE,
    ]).present?
  end

  def delete_prohibited?
    (statuses & [
      CLIENT_DELETE_PROHIBITED,
      SERVER_DELETE_PROHIBITED,
      CLIENT_TRANSFER_PROHIBITED,
      SERVER_TRANSFER_PROHIBITED,
      PENDING_CREATE,
      PENDING_TRANSFER,
      PENDING_UPDATE,
      PENDING_DELETE
    ]).present?
  end

  def clear_address_modifications
    return unless modifies_address?

    remove_address
  end

  def modifies_address?
    modified = false
    self.class.address_attribute_names.each { |field| modified = true if changes.key?(field) }

    modified
  end

  def update_related_whois_records
    # not doing anything if no real changes
    ignored_columns = %w[updated_at created_at statuses status_notes]

    return if (previous_changes.keys - ignored_columns).empty?

    names = related_domain_descriptions.keys
    UpdateWhoisRecordJob.perform_later(names, 'domain') if names.present?
  end

  def children_log
    log = HashWithIndifferentAccess.new
    log[:legal_documents]= [legal_document_id]
    log
  end

  def remove_address
    self.class.address_attribute_names.each do |attr_name|
      self[attr_name.to_sym] = nil
    end
  end

  def reg_no
    return if priv?
    ident
  end

  def id_code
    return unless priv?
    ident
  end

  def ident_country
    Country.new(ident_country_code)
  end

  def linked?
    registrant_domains.any? || domain_contacts.any?
  end

  def domain_names_with_roles
    domain_names = {}

    registrant_domains.pluck(:name).each do |domain_name|
      domain_names[domain_name] ||= Set.new
      domain_names[domain_name] << Registrant.name.underscore.to_sym
    end

    domain_contacts.each do |domain_contact|
      domain_names[domain_contact.domain.name] ||= Set.new
      domain_names[domain_contact.domain.name] << domain_contact.type.underscore.to_sym
    end

    domain_names
  end

  def address=(address)
    self.street = address.street
    self.zip = address.zip
    self.city = address.city
    self.state = address.state
    self.country_code = address.country_code
  end

  def address
    Address.new(street, zip, city, state, country_code)
  end

  def managed_by?(registrant_user)
    ident == registrant_user.ident
  end

  def registrant?
    registrant_domains.any?
  end

  def deletable?
    !linked?
  end

  def ident_human_description
    description = "[#{ident_country_code} #{ident_type}]"
    description.prepend("#{ident} ") if ident.present?

    description
  end

  def as_csv_row
    [
      name,
      code,
      ident_human_description,
      email,
      created_at.to_formatted_s(:db),
      registrar,
      phone,
    ]
  end

  def self.csv_header
    ['Name', 'ID', 'Ident', 'E-mail', 'Created at', 'Registrar', 'Phone']
  end

  private

  def group_by_id_and_type(domains_hash_array)
    domains_hash_array.group_by { |d| d[:id] }
                      .transform_values do |v|
                        v.each.with_object(:type)
                         .map(&:[]).flatten
                      end
  end
end
