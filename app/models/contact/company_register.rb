module Contact::CompanyRegister
  extend ActiveSupport::Concern

  COMPANY_STATUSES = {
    'r' => 'registered',
    'l' => 'liquidated',
    'n' => 'bankrupt',
    'k' => 'deleted',
}.freeze

  REGISTERED = 'registered'
  LIQUIDATED = 'liquidated'
  BANKRUPT = 'bankrupt'
  DELETED = 'deleted'

  def company_is_relevant?
    company_register_status == REGISTERED && company_register_status == LIQUIDATED
  end

  def return_company_status
    return unless return_company_data.present?

    status = return_company_data.first[:status].downcase
    COMPANY_STATUSES[status]
  end

  def return_company_data
    return unless org?

    company_register.company_details(registration_number: ident)
  rescue CompanyRegister::NotAvailableError
    []
  end

  def company_register
    @company_register ||= CompanyRegister::Client.new
  end
end
