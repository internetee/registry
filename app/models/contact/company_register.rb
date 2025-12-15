module Contact::CompanyRegister
  extend ActiveSupport::Concern

  REGISTERED = 'R'.freeze
  LIQUIDATED = 'L'.freeze
  BANKRUPT = 'N'.freeze
  DELETED = 'K'.freeze

  def return_company_status
    return if return_company_data.blank?

    return_company_data.first[:status]
  end

  def return_company_data
    return unless org?

    company_register.simple_data(registration_number: ident.to_s)
  rescue CompanyRegister::NotAvailableError
    []
  rescue CompanyRegister::SOAPFaultError => e
    Rails.logger.error("SOAP Fault getting company data for #{ident}: #{e.message}")
    raise e
  end

  def return_company_details
    return unless org?

    company_register.company_details(registration_number: ident.to_s)
  rescue CompanyRegister::SOAPFaultError => e
    Rails.logger.error("SOAP Fault getting company details for #{ident}: #{e.message}")
    raise e
  rescue CompanyRegister::NotAvailableError
    []
  end

  def company_register
    @company_register ||= CompanyRegister::Client.new
  end
end
