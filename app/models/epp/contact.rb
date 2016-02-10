class Epp::Contact < Contact
  include EppErrors

  # disable STI, there is type column present
  self.inheritance_column = :sti_disabled

  before_validation :manage_permissions
  def manage_permissions
    return unless update_prohibited? || delete_prohibited?
    add_epp_error('2304', nil, nil, I18n.t(:object_status_prohibits_operation))
    false
  end

  class << self
    # support legacy search
    def find_by_epp_code(code)
      # find_by(code: code.sub(/^CID:/, '')) # legacy support turned off
      find_by(code: code)
    end

    # rubocop: disable Metrics/PerceivedComplexity
    # rubocop: disable Metrics/CyclomaticComplexity
    # rubocop: disable Metrics/AbcSize
    def attrs_from(frame, new_record: false)
      f = frame
      at = {}.with_indifferent_access
      at[:name]       = f.css('postalInfo name').text        if f.css('postalInfo name').present?
      at[:org_name]   = f.css('postalInfo org').text         if f.css('postalInfo org').present?
      at[:email]      = f.css('email').text                  if f.css('email').present?
      at[:fax]        = f.css('fax').text                    if f.css('fax').present?
      at[:phone]      = f.css('voice').text                  if f.css('voice').present?
      at[:city]       = f.css('postalInfo addr city').text   if f.css('postalInfo addr city').present?
      at[:zip]        = f.css('postalInfo addr pc').text     if f.css('postalInfo addr pc').present?
      at[:street]     = f.css('postalInfo addr street').text if f.css('postalInfo addr street').present?
      at[:state]      = f.css('postalInfo addr sp').text     if f.css('postalInfo addr sp').present?
      at[:country_code] = f.css('postalInfo addr cc').text     if f.css('postalInfo addr cc').present?
      at[:auth_info]    = f.css('authInfo pw').text            if f.css('authInfo pw').present?

      legal_frame = f.css('legalDocument').first
      if legal_frame.present?
        at[:legal_documents_attributes] = legal_document_attrs(legal_frame)
      end
      at.merge!(ident_attrs(f.css('ident').first)) if new_record
      at
    end
    # rubocop: enable Metrics/PerceivedComplexity
    # rubocop: enable Metrics/CyclomaticComplexity
    # rubocop: enable Metrics/AbcSize

    def new(frame, registrar)
      return super if frame.blank?

      super(
        attrs_from(frame, new_record: true).merge(
          code: frame.css('id').text,
          registrar: registrar
        )
      )
    end

    def ident_attrs(ident_frame)
      return {} unless ident_attr_valid?(ident_frame)

      {
        ident: ident_frame.text,
        ident_type: ident_frame.attr('type'),
        ident_country_code: ident_frame.attr('cc')
      }
    end

    def ident_attr_valid?(ident_frame)
      return false if ident_frame.blank?
      return false if ident_frame.try('text').blank?
      return false if ident_frame.attr('type').blank?
      return false if ident_frame.attr('cc').blank?

      true
    end

    def legal_document_attrs(legal_frame)
      return [] if legal_frame.blank?
      return [] if legal_frame.try('text').blank?
      return [] if legal_frame.attr('type').blank?

      [{
        body: legal_frame.text,
        document_type: legal_frame.attr('type')
      }]
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

  def epp_code_map # rubocop:disable Metrics/MethodLength
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
        [:ident, :invalid],
        [:ident, :invalid_EE_identity_format],
        [:ident, :invalid_EE_identity_format_update],
        [:ident, :invalid_birthday_format],
        [:ident, :invalid_country_code],
        [:ident_type, :missing],
        [:code, :invalid],
        [:code, :too_long_contact_code]
      ],
      '2302' => [ # Object exists
        [:code, :epp_id_taken]
      ],
      '2305' => [ # Association exists
        [:domains, :exist]
      ],
      '2306' => [ # Parameter policy error
      ]
    }
  end

  # rubocop:disable Metrics/AbcSize
  def update_attributes(frame)
    return super if frame.blank?
    at = {}.with_indifferent_access
    at.deep_merge!(self.class.attrs_from(frame.css('chg'), new_record: false))

    if Setting.client_status_editing_enabled
      at[:statuses] = statuses - statuses_attrs(frame.css('rem'), 'rem') + statuses_attrs(frame.css('add'), 'add')
    end

    legal_frame = frame.css('legalDocument').first
    at[:legal_documents_attributes] = self.class.legal_document_attrs(legal_frame)
    self.deliver_emails = true # turn on email delivery for epp


    # allow to update ident code for legacy contacts
    if frame.css('ident').first
      self.ident_updated_at ||= Time.zone.now # not in use
      ident_frame = frame.css('ident').first

      if ident_frame && ident_attr_valid?(ident_frame)
        org_priv = %w(org priv).freeze
        if ident_country_code.blank? && org_priv.include?(ident_type) && org_priv.include?(ident_frame.attr('type'))
          at.merge!(ident_country_code: ident_frame.attr('cc'), ident_type: ident_frame.attr('type'))
        elsif ident_type == "birthday" && !ident[/\A\d{4}-\d{2}-\d{2}\z/] && (Date.parse(ident) rescue false)
          at.merge!(ident: ident_frame.text)
          at.merge!(ident_country_code: ident_frame.attr('cc')) if ident_frame.attr('cc').present?
        elsif ident_type.blank? && ident_country_code.blank?
          at.merge!(ident_type: ident_frame.attr('type'))
          at.merge!(ident_country_code: ident_frame.attr('cc')) if ident_frame.attr('cc').present?
        else
          throw :epp_error, {code: '2306', msg: I18n.t(:ident_update_error)}
        end
      end
    end

    super(at)
  end
  # rubocop:enable Metrics/AbcSize

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
end
