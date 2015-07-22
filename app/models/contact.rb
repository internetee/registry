class Contact < ActiveRecord::Base
  include Versions # version/contact_version.rb
  include EppErrors

  belongs_to :registrar
  has_many :domain_contacts
  has_many :domains, through: :domain_contacts
  has_many :legal_documents, as: :documentable
  has_many :registrant_domains, class_name: 'Domain', foreign_key: 'registrant_id' # when contant is registrant

  # TODO: remove later
  has_many :depricated_statuses, class_name: 'DepricatedContactStatus', dependent: :destroy 

  accepts_nested_attributes_for :legal_documents

  validates :name, :phone, :email, :ident, :ident_type,
   :street, :city, :zip, :country_code, :registrar, presence: true

  # Phone nr validation is very minimam in order to support legacy requirements
  validates :phone, format: /\+[0-9]{1,3}\.[0-9]{1,14}?/
  validates :email, format: /@/
  validates :ident,
    format: { with: /\d{4}-\d{2}-\d{2}/, message: :invalid_birthday_format },
    if: proc { |c| c.ident_type == 'birthday' }
  validates :ident_country_code, presence: true, if: proc { |c| %w(bic priv).include? c.ident_type }
  validates :code,
    uniqueness: { message: :epp_id_taken },
    format: { with: /\A[\w\-\:]*\Z/i, message: :invalid },
    length: { maximum: 100, message: :too_long_contact_code }
  validate :ident_valid_format?
  validate :uniq_statuses?

  after_initialize do 
    self.statuses = [] if statuses.nil?
    self.status_notes = {} if status_notes.nil?
  end

  before_validation :set_ident_country_code
  before_validation :prefix_code
  before_create :generate_auth_info

  before_update :manage_emails
  def manage_emails
    return nil unless email_changed?
    ContactMailer.email_updated(self).deliver_now
  end

  before_save :manage_statuses
  def manage_statuses
    manage_linked
    manage_ok
  end

  scope :current_registrars, ->(id) { where(registrar_id: id) }

  BIC = 'bic'
  PRIV = 'priv'
  BIRTHDAY = 'birthday'
  PASSPORT = 'passport'

  IDENT_TYPES = [
    BIC,     # Company registry code (or similar)
    PRIV,    # National idendtification number
    BIRTHDAY # Birthday date
  ]

  attr_accessor :deliver_emails

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
      Contact.where('
        NOT EXISTS(
          select 1 from domains d where d.registrant_id = contacts.id
        ) AND NOT EXISTS(
          select 1 from domain_contacts dc where dc.contact_id = contacts.id
        )
      ')
    end

    def destroy_orphans
      logger.info "#{Time.zone.now.utc} - Destroying orphaned contacts\n"
      count = find_orphans.destroy_all.count
      logger.info "#{Time.zone.now.utc} - Successfully destroyed #{count} orphaned contacts\n"
    end

    def privs
      where("ident_type = '#{PRIV}'")
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
  end

  def roid
    "EIS-#{id}"
  end

  def to_s
    name || '[no name]'
  end

  def ident_valid_format?
    case ident_type
    when 'priv'
      case ident_country_code
      when 'EE'
        code = Isikukood.new(ident)
        errors.add(:ident, :invalid_EE_identity_format) unless code.valid?
      end
    end
  end

  def uniq_statuses?
    return true unless statuses.detect { |s| statuses.count(s) > 1 }
    errors.add(:statuses, :not_uniq)
    false
  end

  def bic?
    ident_type == BIC
  end

  def priv?
    ident_type != BIC
  end

  def generate_auth_info
    return if @generate_auth_info_disabled
    self.auth_info = SecureRandom.hex(11)
  end

  def disable_generate_auth_info! # needed for testing
    @generate_auth_info_disabled = true
  end

  def auth_info=(pw)
    self[:auth_info] = pw if new_record?
  end

  def code=(code)
    self[:code] = code if new_record? # cannot change code later
  end

  # rubocop:disable Metrics/CyclomaticComplexity
  def prefix_code
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
  # rubocop:enable Metrics/CyclomaticComplexity

  # used only for contact transfer
  def generate_new_code!
    return nil if registrar.blank?
    registrar.reload # for contact transfer
    self[:code] = "#{registrar.code}:#{SecureRandom.hex(4)}".upcase
  end

  def country
    Country.new(country_code)
  end

  # Find a way to use self.domains with contact
  def domains_owned
    Domain.where(registrant_id: id)
  end

  def relations_with_domain?
    return true if domain_contacts.present? || domains_owned.present?
    false
  end

  # TODO: refactor, it should not allow to destroy with normal destroy,
  # no need separate method
  # should use only in transaction
  def destroy_and_clean
    if relations_with_domain?
      errors.add(:domains, :exist)
      return false
    end
    destroy
  end

  def set_ident_country_code
    return true unless ident_country_code_changed? && ident_country_code.present?
    code = Country.new(ident_country_code)
    if code
      self.ident_country_code = code.alpha2
    else
      errors.add(:ident, :invalid_country_code)
    end
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
    statuses.each_with_index do |status,i|
      self.status_notes[status] = notes[i]
    end
  end

  private

  def manage_linked
    if domains.present?
      statuses << LINKED if statuses.detect { |s| s == LINKED }.blank?
    else
      statuses.delete_if { |s| s == LINKED }
    end
  end

  # rubocop:disable Metrics/CyclomaticComplexity
  def manage_ok
    return unset_ok unless valid?

    case statuses.size
    when 0
      set_ok
    when 1
      set_ok if statuses == [LINKED]
    when 2
      return if statuses.sort == [LINKED, OK]
      unset_ok
    else
      unset_ok
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity

  def unset_ok
    statuses.delete_if { |s| s == OK }
  end

  def set_ok
    statuses << OK if statuses.detect { |s| s == OK }.blank?
  end
end
