class DirectoInvoiceForwardJobJob < ApplicationJob
  queue_as :default

  def perform(monthly: false, dry: false)
    api_url = ENV['directo_invoice_url']
    sales_agent = Setting.directo_sales_agent
    payment_term = Setting.directo_receipt_payment_term
    @prepayment_product_id = Setting.directo_receipt_product_name

    @client = DirectoApi::Client.new(api_url, sales_agent, payment_term)
    monthly ? send_monthly_invoices(dry: dry) : send_receipts(dry: dry)
  end

  def send_receipts
    unsent_invoices = Invoice.where(in_directo: false).non_cancelled

    Rails.logger.info("[DIRECTO] Trying to send #{unsent_invoices.count} prepayment invoices")
    unsent_invoices.each do |invoice|
      unless valid_invoice_conditions?(invoice)
        Rails.logger.info("[DIRECTO] Invoice #{invoice.number} has been skipped") && next
      end

      @client.invoices.add(generate_directo_invoice(invoice: invoice, client: @client,
                                                    product_id: @prepayment_product_id))
    end
    sync_with_directo
  end

  def send_monthly_invoices; end

  def valid_invoice_conditions?(invoice)
    if invoice.account_activity.nil? || invoice.account_activity.bank_transaction.nil? ||
       invoice.account_activity.bank_transaction.sum.nil? ||
       invoice.account_activity.bank_transaction.sum != invoice.total
      false
    end
    true
  end

  def generate_directo_invoice(invoice:, client:, product_id:)
    inv = client.invoices.new
    inv = create_invoice_meta(directo_invoice: inv, invoice: invoice)
    inv = create_invoice_line(invoice: invoice, directo_invoice: inv, product_id: product_id)

    inv
  end

  def create_invoice_meta(directo_invoice:, invoice:)
    directo_invoice.customer = create_invoice_customer(invoice: invoice)
    directo_invoice.date = invoice.issue_date.strftime('%Y-%m-%d') # Mapped
    directo_invoice.transaction_date =
      invoice.account_activity.bank_transaction&.paid_at&.strftime('%Y-%m-%d') # Mapped
    directo_invoice.number = invoice.number # Mapped
    directo_invoice.currency = invoice.currency # Mapped
    directo_invoice.language = 'ENG' # Hardcoded

    directo_invoice
  end

  def create_invoice_line(invoice:, directo_invoice:, product_id:)
    line = directo_invoice.lines.new
    line.code = product_id # MAPPED
    line.description = invoice.result.auction.domain_name # MAPPED
    line.quantity = 1 # MAPPED
    line.price = ActionController::Base.helpers.
                 number_with_precision(invoice.subtotal, precision: 2, separator: ".") # MAPPED
    directo_invoice.lines.add(line)

    directo_invoice
  end

  def create_invoice_customer(invoice:)
    customer = Directo::Customer.new
    customer.code = invoice.buyer.accounting_customer_code # MAPPED

    customer
  end

  def sync_with_directo
    res = @client.invoices.deliver(ssl_verify: false)
    Rails.logger.info("[Directo] Directo responded with code: #{res.code}, body: #{res.body}")
    update_invoice_directo_state(res.body) if res.code == '200'
  rescue SocketError, Errno::ECONNREFUSED, Timeout::Error, Errno::EINVAL, Errno::ECONNRESET,
         EOFError, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError
    Rails.logger.info("[Directo] Failed. Responded with code: #{res.code}, body: #{res.body}")
  end

  def update_invoice_directo_state(xml)
    Nokogiri::XML(xml).css('Result').each do |res|
      inv = Invoice.find_by(number: res.attributes['docid'].value.to_i)
      mark_invoice_as_sent(invoice: inv, data: res)
    end
  end

  def mark_invoice_as_sent(invoice:, data:)
    invoice.directo_records.create!(response: data.as_json.to_h, invoice_number: invoice.number)
    invoice.update_columns(in_directo: true)
    Rails.logger.info("[DIRECTO] Invoice #{invoice.number} was pushed and return is #{data.as_json.to_h.inspect}")
  end
end
