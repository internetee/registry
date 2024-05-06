module Contact::CompanyRegister
  extend ActiveSupport::Concern

  COMPANY_STATUSES = {
    'r' => 'registered',
    'l' => 'liquidated',
    'n' => 'bankrupt',
    'k' => 'deleted',
  }.freeze

  REGISTERED = 'registered'.freeze
  LIQUIDATED = 'liquidated'.freeze
  BANKRUPT = 'bankrupt'.freeze
  DELETED = 'deleted'.freeze

  def company_is_relevant?
    company_register_status == REGISTERED && company_register_status == LIQUIDATED
  end

  def return_company_status
    return if return_company_data.blank?

    status = return_company_data.first[:status].downcase
    COMPANY_STATUSES[status]
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

  def return_entries_and_rulings
    return unless org?

    company_register.entries_and_rulings(start_at: '2019-01-18T11:57:00', ends_at: '2019-01-19T11:57:00')
  rescue CompanyRegister::NotAvailableError
    []
  end

  def company_register
    @company_register ||= CompanyRegister::Client.new
  end
end
