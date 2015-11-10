class Registrar::PaymentsController < RegistrarController
  skip_authorization_check # actually anyone can pay, no problems at all
  skip_before_action :authenticate_user!, :check_ip, only: [:back]
  before_action :check_bank

  # to handle existing model we should
  # get invoice_id and then get reference_number
  # build BankTransaction without connection with right reference number
  # do not connect transaction and invoice
  def pay
    invoice = Invoice.find(params[:invoice_id])

    render text: "You are trying to pay with #{params[:bank]} for #{invoice.reference_no}"
  end

  def cancel

  end

  # connect invoice and transaction
  # both back and IPN
  def back

  end

  private
  def banks
    ENV['payments_banks'].split(",").map(&:strip)
  end

  def check_bank
    raise StandardError.new("Not Implemented bank") unless banks.include?(params[:bank])
  end

end
