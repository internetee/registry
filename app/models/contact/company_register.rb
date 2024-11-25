module Contact::CompanyRegister
  extend ActiveSupport::Concern

  REGISTERED = 'R'.freeze
  LIQUIDATED = 'L'.freeze
  BANKRUPT = 'N'.freeze
  DELETED = 'K'.freeze

  def company_is_relevant?
    company_register_status == REGISTERED && company_register_status == LIQUIDATED
  end

  def return_company_status
    Rails.logger.info "ident: #{ident}"
    Rails.logger.info "org?: #{org?}"
    Rails.logger.info "return_company_data: #{return_company_data.inspect}"

    return if return_company_data.blank?

    return_company_data.first[:status]
  end

  def return_company_data
    return unless org?

    company_register.simple_data(registration_number: ident)
  rescue CompanyRegister::NotAvailableError
    Rails.logger.info "ERROR HAPPENED: CompanyRegister::NotAvailableError"
    []
  end

  def return_company_details
    return unless org?

    company_register.company_details(registration_number: ident)
  rescue CompanyRegister::NotAvailableError
    []
  end

  def company_register
    @company_register ||= CompanyRegister::Client.new
  end
end
