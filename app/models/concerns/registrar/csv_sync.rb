module Registrar::CsvSync
  extend ActiveSupport::Concern
  include CsvSync::ModelConfig

  FIELD_DEFINITIONS = {
    code: {
      key: true,
      default_export: true,
      default_import: false,
      type: :string,
    },
    name: { default_export: true, default_import: true, type: :string },
    reg_no: { default_export: true, default_import: true, type: :string },
    email: { default_export: true, default_import: true, type: :string },
    billing_email: { default_export: true, default_import: true, type: :string },
    phone: { default_export: true, default_import: true, type: :string },
    website: { default_export: true, default_import: true, type: :string },
    language: { default_export: true, default_import: true, type: :string },
    test_registrar: { default_export: true, default_import: false, type: :boolean },
    address_street: { default_export: true, default_import: true, type: :string },
    address_zip: { default_export: true, default_import: true, type: :string },
    address_city: { default_export: true, default_import: true, type: :string },
    address_state: { default_export: true, default_import: true, type: :string },
    address_country_code: { default_export: true, default_import: true, type: :string },
    vat_no: { default_export: true, default_import: true, type: :string },
    vat_rate: { default_export: true, default_import: true, type: :decimal },
    iban: { default_export: true, default_import: true, type: :string },
    accounting_customer_code: { default_export: true, default_import: false, type: :string },
    reference_no: { default_export: true, default_import: false, type: :string },
    legaldoc_optout: { default_export: true, default_import: true, type: :boolean },
    legaldoc_optout_comment: { default_export: true, default_import: true, type: :string },
    accept_pdf_invoices: { default_export: true, default_import: true, type: :boolean },
    settings: { default_export: true, default_import: true, type: :json },
    accreditation_date: { default_export: true, default_import: false, type: :datetime },
    accreditation_expire_date: { default_export: true, default_import: false, type: :datetime },
  }.freeze

end
