require 'deserializers/xml/legal_document'
require 'deserializers/xml/ident'
require 'deserializers/xml/contact'

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
      at = ::Deserializers::Xml::Contact.new(frame).call
      ident_attrs = ::Deserializers::Xml::Ident.new(frame).call
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
