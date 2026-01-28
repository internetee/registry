module Contact::CompanyRegister
  extend ActiveSupport::Concern

  REGISTERED = 'R'.freeze
  LIQUIDATED = 'L'.freeze
  BANKRUPT = 'N'.freeze
  DELETED = 'K'.freeze
  NOT_FOUND = 'X'.freeze

  def return_company_status
    return if return_company_data.blank?

    return_company_data.first[:status]
  end

  def return_company_data
    return unless is_contact_estonian_org?

    company_register.simple_data(registration_number: ident.to_s)
  rescue CompanyRegister::NotAvailableError
    []
  rescue CompanyRegister::SOAPFaultError => e
    Rails.logger.error("SOAP Fault getting company data for #{ident}: #{e.message}")
    raise e
  end

  def return_company_details
    return unless is_contact_estonian_org?

    company_register.company_details(registration_number: ident.to_s)
  rescue CompanyRegister::SOAPFaultError => e
    Rails.logger.error("SOAP Fault getting company details for #{ident}: #{e.message}")
    raise e
  rescue CompanyRegister::NotAvailableError
    []
  end

  def e_invoice_recipients
    return unless is_contact_estonian_org?

    company_register.e_invoice_recipients(registration_numbers: ident.to_s)
  rescue CompanyRegister::SOAPFaultError => e
    Rails.logger.error("SOAP Fault getting company details for #{ident}: #{e.message}")
    raise e
  rescue CompanyRegister::NotAvailableError
    []
  end

  def org_contact_accept_e_invoice?
    return unless is_contact_estonian_org?

    result = e_invoice_recipients.first
    result.status == 'OK'
  end

  def is_contact_estonian_org?
    org? && ident_country_code == 'EE'
  end

  def company_register
    @company_register ||= CompanyRegister::Client.new
  end
end
