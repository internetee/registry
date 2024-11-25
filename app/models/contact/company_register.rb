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
    company_register_2 = CompanyRegister::Client.new
    Rails.logger.info "ident: #{ident}"
    Rails.logger.info "org?: #{org?}"
    # Rails.logger.info "return_company_data: #{return_company_data.inspect}"
    return_company_data_2 = company_register_2.simple_data(registration_number: ident)
    Rails.logger.info "return_company_data_2: #{return_company_data_2.inspect}"
    return if return_company_data_2.blank?

    return_company_data_2.first[:status]
  end

  def return_company_data
    return unless org?

    company_register.simple_data(registration_number: ident)
  rescue CompanyRegister::NotAvailableError
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
