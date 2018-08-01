class Contact < ApplicationRecord
  include Versions # version/contact_version.rb
  include EppErrors
  include UserEvents
  include Concerns::Contact::Transferable
  include Concerns::Contact::Identical
  include Concerns::Contact::Disclosable

  belongs_to :original, class_name: self.name
  belongs_to :registrar, required: true
  has_many :domain_contacts
  has_many :domains, through: :domain_contacts
  has_many :legal_documents, as: :documentable
  has_many :registrant_domains, class_name: 'Domain', foreign_key: 'registrant_id'
  has_many :actions, dependent: :destroy

  has_paper_trail class_name: "ContactVersion", meta: { children: :children_log }

  attr_accessor :legal_document_id
  alias_attribute :kind, :ident_type
  alias_attribute :copy_from_id, :original_id # Old attribute name; for PaperTrail

  accepts_nested_attributes_for :legal_documents

  validates :name, :email, presence: true
  validates :street, :city, :zip, :country_code, presence: true, if: 'self.class.address_processing?'

  validates :phone, presence: true, e164: true, phone: true

  validates :email, format: /@/
  validates :email, email_format: { message: :invalid }, if: proc { |c| c.email_changed? }

  validates :code,
    uniqueness: { message: :epp_id_taken },
    format: { with: /\A[\w\-\:\.\_]*\z/i, message: :invalid },
    length: { maximum: 100, message: :too_long_contact_code }
  validates_associated :identifier

  validate :validate_html
  validate :validate_country_code, if: 'self.class.address_processing?'

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

  after_save :update_related_whois_records

  ORG = 'org'
  PRIV = 'priv'

  # For foreign private persons who has no national identification number
  BIRTHDAY = 'birthday'.freeze

  # From old registry software ("Fred"). No new contact can be created with this status
  PASSPORT = 'passport'

  #
  # STATUSES
  #
  # Requests to delete the object MUST be rejected.
  CLIENT_DELETE_PROHIBITED = 'clientDeleteProhibited'
  SERVER_DELETE_PROHIBITED = 'serverDeleteProhibited'

  # Requests to transfer the object MUST be rejected.
  CLIENT_TRANSFER_PROHIBITED = 'clientTransferProhibited'
  SERVER_TRANSFER_PROHIBITED = 'serverTransferProhibited'

  # The contact object has at least one active association with
  # another object, such as a domain object. Servers SHOULD provide
  # services to determine existing object associations.
  # "linked" status MAY be combined with any status.
  LINKED = 'linked'

  # This is the normal status value for an object that has no pending
  # operations or prohibitions. This value is set and removed by the
  # server as other status values are added or removed.
  # "ok" status MAY only be combined with "linked" status.
  OK = 'ok'

  # Requests to update the object (other than to remove this status) MUST be rejected.
  CLIENT_UPDATE_PROHIBITED = 'clientUpdateProhibited'
  SERVER_UPDATE_PROHIBITED = 'serverUpdateProhibited'

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
  PENDING_CREATE = 'pendingCreate'
  # "pendingTransfer" status MUST NOT be combined with either
  # "clientTransferProhibited" or "serverTransferProhibited" status.
  PENDING_TRANSFER = 'pendingTransfer'
  # "pendingUpdate" status MUST NOT be combined with either
  # "clientUpdateProhibited" or "serverUpdateProhibited" status.
  PENDING_UPDATE = 'pendingUpdate'
  # "pendingDelete" MUST NOT be combined with either
  # "clientDeleteProhibited" or "serverDeleteProhibited" status.
  PENDING_DELETE = 'pendingDelete'

  STATUSES = [
    CLIENT_DELETE_PROHIBITED, SERVER_DELETE_PROHIBITED,
    CLIENT_TRANSFER_PROHIBITED,
    SERVER_TRANSFER_PROHIBITED, CLIENT_UPDATE_PROHIBITED, SERVER_UPDATE_PROHIBITED,
    OK, PENDING_CREATE, PENDING_DELETE, PENDING_TRANSFER,
    PENDING_UPDATE, LINKED
  ]

  CLIENT_STATUSES = [
    CLIENT_DELETE_PROHIBITED, CLIENT_TRANSFER_PROHIBITED,
    CLIENT_UPDATE_PROHIBITED
  ]

  SERVER_STATUSES = [
    SERVER_UPDATE_PROHIBITED,
    SERVER_DELETE_PROHIBITED,
    SERVER_TRANSFER_PROHIBITED
  ]
  #
  # END OF STATUSES
  #

  class << self
    def search_by_query(query)
      res = search(code_cont: query).result
      res.reduce([]) { |o, v| o << { id: v[:id], display_key: "#{v.name} (#{v.code})" } }
    end

    def find_orphans
      where('
        NOT EXISTS(
          select 1 from domains d where d.registrant_id = contacts.id
        ) AND NOT EXISTS(
          select 1 from domain_contacts dc where dc.contact_id = contacts.id
        )
      ')
    end

    def find_linked
      where('
        EXISTS(
          select 1 from domains d where d.registrant_id = contacts.id
        ) OR EXISTS(
          select 1 from domain_contacts dc where dc.contact_id = contacts.id
        )
      ')
    end

    def filter_by_states in_states
      states = Array(in_states).dup
      scope  = all

      # all contacts has state ok, so no need to filter by it
      scope = scope.where("NOT contacts.statuses && ?::varchar[]", "{#{(STATUSES - [OK, LINKED]).join(',')}}") if states.delete(OK)
      scope = scope.find_linked if states.delete(LINKED)
      scope = scope.where("contacts.statuses @> ?::varchar[]", "{#{states.join(',')}}") if states.any?
      scope
    end

    # To leave only new ones we need to check
    # if contact was at any time used in domain.
    # This can be checked by domain history.
    # This can be checked by saved relations in children attribute
    def destroy_orphans
      STDOUT << "#{Time.zone.now.utc} - Destroying orphaned contacts\n" unless Rails.env.test?

      counter = Counter.new
      find_orphans.find_each do |contact|
        ver_scope = []
        %w(admin_contacts tech_contacts registrant).each do |type|
          ver_scope << "(children->'#{type}')::jsonb <@ json_build_array(#{contact.id})::jsonb"
        end
        next if DomainVersion.where("created_at > ?", Time.now - Setting.orphans_contacts_in_months.to_i.months).where(ver_scope.join(" OR ")).any?
        next if contact.linked?

        contact.destroy
        counter.next
        STDOUT << "#{Time.zone.now.utc} Contact.destroy_orphans: ##{contact.id} (#{contact.name})\n" unless Rails.env.test?
      end

      STDOUT << "#{Time.zone.now.utc} - Successfully destroyed #{counter} orphaned contacts\n" unless Rails.env.test?
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

    def to_csv
      CSV.generate do |csv|
        csv << column_names
        all.each do |contact|
        csv << contact.attributes.values_at(*column_names)
        end
      end
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

    def registrant_user_contacts(registrant_user)
      registrant_user_direct_contacts(registrant_user)
        .or(registrant_user_indirect_contacts(registrant_user))
    end

    def registrant_user_direct_contacts(registrant_user)
      where(ident_type: PRIV, ident: registrant_user.ident, ident_country_code: registrant_user
                                                                                  .country.alpha2)
    end

    private

    def registrant_user_indirect_contacts(registrant_user)
      ident = registrant_user.companies.collect(&:registration_number)

      where(ident_type: ORG,
            ident: ident,
            ident_country_code: registrant_user.country.alpha2)
    end
  end

  def roid
    "EIS-#{id}"
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

  # TODO: refactor, it should not allow to destroy with normal destroy,
  # no need separate method
  # should use only in transaction
  def destroy_and_clean frame
    if linked?
      errors.add(:domains, :exist)
      return false
    end

    legal_document_data = Epp::Domain.parse_legal_document_from_frame(frame)

    if legal_document_data

        doc = LegalDocument.create(
            documentable_type: Contact,
            document_type:     legal_document_data[:type],
            body:              legal_document_data[:body]
        )
        self.legal_documents = [doc]
        self.legal_document_id = doc.id
        self.save
    end
    destroy
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
      @desc[dom.name] ||= []
      @desc[dom.name] << :registrant
    end

    domain_contacts.each do |dc|
      @desc[dc.domain.name] ||= []
      @desc[dc.domain.name] << dc.name.downcase.to_sym
      @desc[dc.domain.name] = @desc[dc.domain.name].compact
    end

    @desc
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

  def strip_email
    self.email = email.to_s.strip
  end


  # what we can do load firstly by registrant
  # if total is smaller than needed, the load more
  # we also need to sort by valid_to
  # todo: extract to drapper. Then we can remove Domain#roles
  def all_domains(page: nil, per: nil, params:)
    # compose filter sql
    filter_sql = case params[:domain_filter]
      when "Registrant".freeze
        %Q{select id from domains where registrant_id=#{id}}
      when AdminDomainContact.to_s, TechDomainContact.to_s
        %Q{select domain_id from domain_contacts where contact_id=#{id} AND type='#{params[:domain_filter]}'}
      else
        %Q{select domain_id from domain_contacts where contact_id=#{id}  UNION select id from domains where registrant_id=#{id}}
    end

    # get sorting rules
    sorts = params.fetch(:sort, {}).first || []
    sort  = Domain.column_names.include?(sorts.first) ? sorts.first : "valid_to"
    order = {"asc"=>"desc", "desc"=>"asc"}[sorts.second] || "desc"


    # fetch domains
    domains  = Domain.where("domains.id IN (#{filter_sql})")
    domains = domains.includes(:registrar).page(page).per(per)

    if sorts.first == "registrar_name".freeze
      # using small rails hack to generate outer join
      domains = domains.includes(:registrar).where.not(registrars: {id: nil}).order("registrars.name #{order} NULLS LAST")
    else
      domains = domains.order("#{sort} #{order} NULLS LAST")
    end



    # adding roles. Need here to make faster sqls
    domain_c = Hash.new([])
    registrant_domains.where(id: domains.map(&:id)).each{|d| domain_c[d.id] |= ["Registrant".freeze] }
    DomainContact.where(contact_id: id, domain_id: domains.map(&:id)).each{|d| domain_c[d.domain_id] |= [d.type] }
    domains.each{|d| d.roles = domain_c[d.id].uniq}

    domains
  end

  def update_prohibited?
    (statuses & [
      CLIENT_UPDATE_PROHIBITED,
      SERVER_UPDATE_PROHIBITED,
      CLIENT_TRANSFER_PROHIBITED,
      SERVER_TRANSFER_PROHIBITED,
      PENDING_CREATE,
      PENDING_TRANSFER,
      PENDING_UPDATE,
      PENDING_DELETE
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

  def update_related_whois_records
    # not doing anything if no real changes
    return if changes.slice(*(self.class.column_names - ["updated_at", "created_at", "statuses", "status_notes"])).empty?

    names = related_domain_descriptions.keys
    UpdateWhoisRecordJob.enqueue(names, 'domain') if names.present?
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
end
