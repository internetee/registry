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

    retries = 1
    begin
      company_register.simple_data(registration_number: ident)
    rescue CompanyRegister::NotAvailableError
      Rails.logger.info "CompanyRegister::NotAvailableError occurred, attempt #{retries}"
      if retries <= 3  # максимум 3 попытки
        sleep 1  # ждем 1 секунду
        retries += 1
        retry
      else
        Rails.logger.error "Failed to fetch company data after #{retries-1} retries"
        []
      end
    end
  end

  def return_company_details
    return unless org?

    retries = 1
    begin
      company_register.company_details(registration_number: ident)
    rescue CompanyRegister::NotAvailableError
      Rails.logger.info "CompanyRegister::NotAvailableError occurred, attempt #{retries}"
      if retries <= 3  # максимум 3 попытки
        sleep 1  # ждем 1 секунду
        retries += 1
        retry
      else
        Rails.logger.error "Failed to fetch company details after #{retries-1} retries"
        []
      end
    end
  end

  def company_register
    @company_register ||= CompanyRegister::Client.new
  end
end
