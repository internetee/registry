# rubocop: disable Metrics/ClassLength
class Epp::Contact < Contact
  include EppErrors

  # disable STI, there is type column present
  self.inheritance_column = :sti_disabled

  class << self
    # rubocop: disable Metrics/PerceivedComplexity
    # rubocop: disable Metrics/CyclomaticComplexity
    # rubocop: disable Metrics/MethodLength
    def attrs_from(frame, rem = nil)
      f = frame
      at = {}.with_indifferent_access
      if rem
        at[:name]         = nil if f.css('postalInfo name').present? 
        at[:org_name]     = nil if f.css('postalInfo org').present? 
        at[:email]        = nil if f.css('email').present?
        at[:fax]          = nil if f.css('fax').present?
        at[:phone]        = nil if f.css('voice').present?
        at[:city]         = nil if f.css('postalInfo addr city').present?
        at[:zip]          = nil if f.css('postalInfo addr pc').present?
        at[:street]       = nil if f.css('postalInfo addr street').present?
        at[:state]        = nil if f.css('postalInfo addr sp').present?
        at[:country_code] = nil if f.css('postalInfo addr cc').present?
      else
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
      end

      legal_frame = f.css('legalDocument').first
      if legal_frame.present?
        at[:legal_documents_attributes] = legal_document_attrs(legal_frame) 
      end
      at.merge!(ident_attrs(f.css('ident').first))
      at
    end
    # rubocop: enable Metrics/MethodLength
    # rubocop: enable Metrics/PerceivedComplexity
    # rubocop: enable Metrics/CyclomaticComplexity

    def new(frame, registrar)
      return super if frame.blank?

      super(
        attrs_from(frame).merge(
          code: frame.css('id').text,
          registrar: registrar
        )
      )
    end

    def ident_attrs(ident_frame)
      return {} if ident_frame.blank?
      return {} if ident_frame.try('text').blank?
      return {} if ident_frame.attr('type').blank?
      return {} if ident_frame.attr('cc').blank?

      {
        ident: ident_frame.text,
        ident_type: ident_frame.attr('type'),
        ident_country_code: ident_frame.attr('cc')
      }
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
  end

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
        [:ident, :invalid_birthday_format]
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

  def update_attributes(frame)
    return super if frame.blank?
    at = {}.with_indifferent_access
    at.deep_merge!(self.class.attrs_from(frame.css('rem'), 'rem'))
    at.deep_merge!(self.class.attrs_from(frame.css('add')))
    at.deep_merge!(self.class.attrs_from(frame.css('chg')))
    at.merge!(self.class.ident_attrs(frame.css('ident').first))
    legal_frame = frame.css('legalDocument').first
    at[:legal_documents_attributes] = self.class.legal_document_attrs(legal_frame) 

    super(at)
  end
end
# rubocop: enable Metrics/ClassLength
