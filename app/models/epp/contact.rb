require 'deserializers/xml/legal_document'
require 'deserializers/xml/ident'

class Epp::Contact < Contact
  include EppErrors

  # disable STI, there is type column present
  self.inheritance_column = :sti_disabled

  before_validation :manage_permissions

  def manage_permissions
    return unless update_prohibited? || delete_prohibited?
    add_epp_error('2304', nil, nil, I18n.t(:object_status_prohibits_operation))
    throw(:abort)
  end

  class << self
    # support legacy search
    def find_by_epp_code(code)
      # find_by(code: code.sub(/^CID:/, '')) # legacy support turned off
      find_by(code: code)
    end

    def attrs_from(frame, new_record: false)
      f = frame
      at = {}.with_indifferent_access
      at[:name]       = f.css('postalInfo name').text        if f.css('postalInfo name').present?
      at[:org_name]   = f.css('postalInfo org').text         if f.css('postalInfo org').present?
      at[:email]      = f.css('email').text                  if f.css('email').present?
      at[:fax]        = f.css('fax').text                    if f.css('fax').present?
      at[:phone]      = f.css('voice').text                  if f.css('voice').present?

      if address_processing?
        at[:city] = f.css('postalInfo addr city').text if f.css('postalInfo addr city').present?
        at[:zip] = f.css('postalInfo addr pc').text if f.css('postalInfo addr pc').present?
        at[:street] = f.css('postalInfo addr street').text if f.css('postalInfo addr street').present?
        at[:state] = f.css('postalInfo addr sp').text if f.css('postalInfo addr sp').present?
        at[:country_code] = f.css('postalInfo addr cc').text if f.css('postalInfo addr cc').present?
      end

      at[:auth_info]    = f.css('authInfo pw').text            if f.css('authInfo pw').present?

      ident_attrs = ::Deserializers::Xml::Ident.new(f).call
      at.merge!(ident_attrs) if new_record
      at
    end

    def new(frame, registrar)
      return super if frame.blank?

      super(
        attrs_from(frame, new_record: true).merge(
          code: frame.css('id').text,
          registrar: registrar
        )
      )
    end

    def check_availability(codes)
      codes = [codes] if codes.is_a?(String)

      res = []
      codes.each do |x|
        contact = find_by_epp_code(x)
        if contact
          res << { code: contact.code, avail: 0, reason: 'in use' }
        else
          res << { code: x, avail: 1 }
        end
      end

      res
    end

  end
  delegate :ident_attr_valid?, to: :class

  def epp_code_map
    {
      '2003' => [ # Required parameter missing
        [:name,   :blank],
        [:email,  :blank],
        [:phone,  :blank],
        [:city,   :blank],
        [:zip,    :blank],
        [:street, :blank],
        [:country_code, :blank]
      ],
      '2005' => [ # Value syntax error
        [:name, :invalid],
        [:phone, :invalid],
        [:email, :invalid],
        [:country_code, :invalid],
        [:code, :invalid],
        [:code, :too_long_contact_code]
      ],
      '2302' => [ # Object exists
        [:code, :epp_id_taken]
      ],
      '2305' => [ # Association exists
        [:domains, :exist]
      ]
    }
  end

  def update_attributes(frame, current_user)
    return super if frame.blank?
    at = {}.with_indifferent_access
    at.deep_merge!(self.class.attrs_from(frame.css('chg'), new_record: false))

    if Setting.client_status_editing_enabled
      at[:statuses] = statuses - statuses_attrs(frame.css('rem'), 'rem') + statuses_attrs(frame.css('add'), 'add')
    end

    if doc = attach_legal_document(::Deserializers::Xml::LegalDocument.new(frame).call)
      frame.css("legalDocument").first.content = doc.path if doc&.persisted?
      self.legal_document_id = doc.id
    end

    ident_frame = frame.css('ident').first

    # https://github.com/internetee/registry/issues/576
    if ident_frame
      if identifier.valid?
        submitted_ident = Ident.new(code: ident_frame.text,
                                    type: ident_frame.attr('type'),
                                    country_code: ident_frame.attr('cc'))

        if submitted_ident != identifier
          add_epp_error('2308', nil, nil, I18n.t('epp.contacts.errors.valid_ident'))
          return
        end
      else
        ident_update_attempt = ident_frame.text.present? && (ident_frame.text != ident)

        if ident_update_attempt
          add_epp_error('2308', nil, nil, I18n.t('epp.contacts.errors.ident_update'))
          return
        end

        identifier = Ident.new(code: ident,
                               type: ident_frame.attr('type'),
                               country_code: ident_frame.attr('cc'))

        identifier.validate

        self.identifier = identifier
        self.ident_updated_at ||= Time.zone.now
      end
    end

    self.upid = current_user.registrar.id if current_user.registrar
    self.up_date = Time.zone.now

    self.attributes = at

    email_changed = will_save_change_to_email?
    old_email = email_was
    updated = save

    if updated && email_changed && registrant?
      ContactMailer.email_changed(contact: self, old_email: old_email).deliver_now
    end

    updated
  end

  def statuses_attrs(frame, action)
    status_list = status_list_from(frame)

    if action == 'rem'
      to_destroy = []
      status_list.each do |status|
        if statuses.include?(status)
          to_destroy << status
        else
          add_epp_error('2303', 'status', status, [:contact_statuses, :not_found])
        end
      end

      return to_destroy
    else
      return status_list
    end
  end

  def status_list_from(frame)
    status_list = []

    frame.css('status').each do |status|
      unless Contact::CLIENT_STATUSES.include?(status['s'])
        add_epp_error('2303', 'status', status['s'], [:domain_statuses, :not_found])
        next
      end

      status_list << status['s']
    end

    status_list
  end

  def attach_legal_document(legal_document_data)
    return unless legal_document_data

    legal_documents.create(
        document_type: legal_document_data[:type],
        body: legal_document_data[:body]
    )
  end

  def add_legal_file_to_new frame
    legal_document_data = ::Deserializers::Xml::LegalDocument.new(frame).call
    return unless legal_document_data

    doc = LegalDocument.create(
        documentable_type: Contact,
        document_type:     legal_document_data[:type],
        body:              legal_document_data[:body]
    )
    self.legal_documents = [doc]

    frame.css("legalDocument").first.content = doc.path if doc&.persisted?
    self.legal_document_id = doc.id
  end
end
