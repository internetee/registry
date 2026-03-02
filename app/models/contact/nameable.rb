module Contact::Nameable
  extend ActiveSupport::Concern

  included do
    NAME_REGEXP = /([\u00A1-\u00B3\u00B5-\u00BF\u0021-\u0026\u0028-\u002C\u003A-\u0040]|
      [\u005B-\u005F\u007B-\u007E\u2040-\u206F\u20A0-\u20BF\u2100-\u218F])/x

    RESTRICTED_ORG_TERMS_FOR_PRIV = [
      'Ltd', 'PLC', 'LLC', 'Corp', 'Inc', 'Co',
      'Limited', 'Public Limited Company', 'Limited Liability Company',
      'Corporation', 'Incorporated'
    ].freeze

    RESTRICTED_ORG_TERMS_FOR_PRIV_EE = [
      'OÜ', 'AS', 'SA', 'MTÜ', 'TÜ', 'UÜ',
      'osaühing', 'aktsiaselt', 'sihtasutus',
      'mittetulundusühing', 'täisühing', 'usaldusühing'
    ].freeze

    RESTRICTED_ORG_TERMS_FOR_PRIV_DE = [
      'GmbH', 'AG',
      'Gesellschaft mit beschränkter Haftung', 'Aktiengesellschaft'
    ].freeze

    RESTRICTED_ORG_TERMS_FOR_PRIV_FI = [
      'Oy', 'Oyj',
      'Osakeyhtiö', 'Julkinen osakeyhtiö'
    ].freeze

    RESTRICTED_ORG_TERMS_FOR_PRIV_SE = [
      'AB',
      'Aktiebolag'
    ].freeze

    RESTRICTED_ORG_TERMS_FOR_PRIV_LV = [
      'SIA', 'AS',
      'Sabiedrība ar ierobežotu atbildību', 'Akciju sabiedrība'
    ].freeze

    RESTRICTED_ORG_TERMS_FOR_PRIV_LT = [
      'UAB', 'AB',
      'Uždaroji akcinė bendrovė', 'Akcinė bendrovė'
    ].freeze

    RESTRICTED_ORG_TERMS_FOR_PRIV_FR = [
      'SARL', 'SAS', 'S.A.',
      'Société à responsabilité limitée',
      'Société par actions simplifiée', 'Société Anonyme'
    ].freeze

    RESTRICTED_ORG_TERMS_FOR_PRIV_IT = [
      'S.r.l.', 'S.p.A.',
      'Società a responsabilità limitata', 'Società per Azioni'
    ].freeze

    RESTRICTED_ORG_TERMS_FOR_PRIV_NL = [
      'B.V.', 'N.V.',
      'Besloten Vennootschap', 'Naamloze Vennootschap'
    ].freeze

    RESTRICTED_ORG_TERMS_FOR_PRIV_PL = [
      'Sp. z o.o.', 'S.A.',
      'Spółka z ograniczoną odpowiedzialnością', 'Spółka Akcyjna'
    ].freeze

    COUNTRY_SPECIFIC_ORG_TERMS = {
      'EE' => RESTRICTED_ORG_TERMS_FOR_PRIV_EE,
      'DE' => RESTRICTED_ORG_TERMS_FOR_PRIV_DE,
      'FI' => RESTRICTED_ORG_TERMS_FOR_PRIV_FI,
      'SE' => RESTRICTED_ORG_TERMS_FOR_PRIV_SE,
      'LV' => RESTRICTED_ORG_TERMS_FOR_PRIV_LV,
      'LT' => RESTRICTED_ORG_TERMS_FOR_PRIV_LT,
      'FR' => RESTRICTED_ORG_TERMS_FOR_PRIV_FR,
      'IT' => RESTRICTED_ORG_TERMS_FOR_PRIV_IT,
      'NL' => RESTRICTED_ORG_TERMS_FOR_PRIV_NL,
      'PL' => RESTRICTED_ORG_TERMS_FOR_PRIV_PL,
    }.freeze

    validates :name, :email, presence: true
    validates :name, length: { maximum: 255, message: :too_long_contact_name }
    validates :name, format: { without: NAME_REGEXP, message: :invalid }, if: -> { priv? }
    validate :validate_org_terms_in_priv_name, if: -> { priv? && name.present? }
  end

  private

  def validate_org_terms_in_priv_name
    restricted_terms = RESTRICTED_ORG_TERMS_FOR_PRIV.dup
    country_terms = COUNTRY_SPECIFIC_ORG_TERMS[ident_country_code]
    restricted_terms.concat(country_terms) if country_terms

    matched_term = restricted_terms.find { |term| name_contains_org_term?(name, term) }
    return unless matched_term

    errors.add(:name, :org_term_in_priv_name, term: matched_term)
  end

  def name_contains_org_term?(contact_name, term)
    escaped = Regexp.escape(term)
    pattern = /(?<=\A|[\s.,-])#{escaped}(?=[\s.,-]|\z)/i
    contact_name.match?(pattern)
  end
end
