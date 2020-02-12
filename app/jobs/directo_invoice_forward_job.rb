class DirectoInvoiceForwardJob < Que::Job
  def run(monthly: false, dry: false)
    @dry = dry
    api_url = ENV['directo_invoice_url']
    sales_agent = Setting.directo_sales_agent
    payment_term = Setting.directo_receipt_payment_term
    @prepayment_product_id = Setting.directo_receipt_product_name

    @client = DirectoApi::Client.new(api_url, sales_agent, payment_term)
    monthly ? send_monthly_invoices : send_receipts
  end

  def send_receipts
    unsent_invoices = Invoice.where(in_directo: false).non_cancelled

    Rails.logger.info("[DIRECTO] Trying to send #{unsent_invoices.count} prepayment invoices")
    unsent_invoices.each do |invoice|
      unless valid_invoice_conditions?(invoice)
        Rails.logger.info "[DIRECTO] Invoice #{invoice.number} has been skipped"
        next
      end
      @client.invoices.add_with_schema(invoice: invoice.as_directo_json, schema: 'prepayment')
    end

    sync_with_directo
  end

  def send_monthly_invoices
    month = Time.now - 1.month

    Registrar.where.not(test_registrar: true).find_each do |registrar|
      next unless registrar.cash_account

      invoice = registrar.monthly_summary(month: month)
      @client.invoices.add_with_schema(invoice: invoice, schema: 'summary')
    end

    # TODO: Invoice number
    sync_with_directo
  end

  def valid_invoice_conditions?(invoice)
    if invoice.account_activity.nil? || invoice.account_activity.bank_transaction.nil? ||
       invoice.account_activity.bank_transaction.sum.nil? ||
       invoice.account_activity.bank_transaction.sum != invoice.total
      return false

    end

    true
  end

  def sync_with_directo
    Rails.logger.info('[Directo] - attempting to send following XML:')
    puts @client.invoices.as_xml

    return if @dry

    res = @client.invoices.deliver(ssl_verify: false)

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

  def self.load_price(account_activity)
    @pricelists ||= {}
    if @pricelists.key? account_activity.price_id
      return @pricelists[account_activity.price_id]
    end

    @pricelists[account_activity.price_id] = account_activity.price
  end

  def last_directo_monthly_number
    min_directo    = Setting.directo_monthly_number_min.presence.try(:to_i)
    max_directo    = Setting.directo_monthly_number_max.presence.try(:to_i)
    last_directo   = [Setting.directo_monthly_number_last.presence.try(:to_i), min_directo]
                     .compact.max || 0

    if max_directo && max_directo <= last_directo
      raise 'Directo counter is out of period'
    end

    last_directo
  end
end
