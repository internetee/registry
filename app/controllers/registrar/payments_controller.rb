class Registrar::PaymentsController < RegistrarController
  protect_from_forgery except: :back

  skip_authorization_check # actually anyone can pay, no problems at all
  skip_before_action :authenticate_user!, :check_ip, only: [:back]
  before_action :check_bank

  # to handle existing model we should
  # get invoice_id and then get number
  # build BankTransaction without connection with right reference number
  # do not connect transaction and invoice
  def pay
    invoice = Invoice.find(params[:invoice_id])
    @bank_link = BankLink::Request.new(params[:bank], invoice, self)
    @bank_link.make_transaction
  end


  # connect invoice and transaction
  # both back and IPN
  def back
    @bank_link = BankLink::Response.new(params[:bank], params)
  end

  private
  def banks
    ENV['payments_banks'].split(",").map(&:strip)
  end

  def check_bank
    raise StandardError.new("Not Implemented bank") unless banks.include?(params[:bank])
  end

end
