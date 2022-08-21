class SendMonthlyInvoicesJob < ApplicationJob
  queue_as :default

  def perform(dry: false)
    @dry = dry
    @month = Time.zone.now - 1.month
    @directo_client = new_directo_client
    @min_directo_num = Setting.directo_monthly_number_min.presence.try(:to_i)
    @max_directo_num = Setting.directo_monthly_number_max.presence.try(:to_i)

    send_monthly_invoices
  end

  def new_directo_client
    DirectoApi::Client.new(ENV['directo_invoice_url'], Setting.directo_sales_agent,
                           Setting.directo_receipt_payment_term)
  end

  def send_monthly_invoices
    Registrar.where.not(test_registrar: true).find_each do |registrar|
      next unless registrar.cash_account

      summary = registrar.monthly_summary(month: @month)
      next if summary.nil?

      invoice = registrar.monthly_invoice(month: @month) || create_invoice(summary, registrar)
      next if invoice.nil? || @dry

      InvoiceMailer.invoice_email(invoice: invoice,
                                  recipient: registrar.billing_email)
                   .deliver_now

      SendEInvoiceJob.set(wait: 1.minute).perform_now(invoice.id, payable: false)

      next if invoice.in_directo

      Rails.logger.info("[DIRECTO] Trying to send monthly invoice #{invoice.number}")
      @directo_client = new_directo_client
      directo_invoices = @directo_client.invoices.add_with_schema(invoice: summary,
                                                                  schema: 'summary')
      next unless directo_invoices.size.positive?

      directo_invoices.last.number = invoice.number
      sync_with_directo
    end
  end

  def create_invoice(summary, registrar)
    vat_rate = ::Invoice::VatRateCalculator.new(registrar: registrar).calculate
    invoice = Invoice.new(
      number: assign_monthly_number,
      issue_date: summary['date'].to_date,
      due_date: summary['date'].to_date,
      currency: 'EUR',
      description: I18n.t('invoice.monthly_invoice_description'),
      seller_name: Setting.registry_juridical_name,
      seller_reg_no: Setting.registry_reg_no,
      seller_iban: Setting.registry_iban,
      seller_bank: Setting.registry_bank,
      seller_swift: Setting.registry_swift,
      seller_vat_no: Setting.registry_vat_no,
      seller_country_code: Setting.registry_country_code,
      seller_state: Setting.registry_state,
      seller_street: Setting.registry_street,
      seller_city: Setting.registry_city,
      seller_zip: Setting.registry_zip,
      seller_phone: Setting.registry_phone,
      seller_url: Setting.registry_url,
      seller_email: Setting.registry_email,
      seller_contact_name: Setting.registry_invoice_contact,
      buyer: registrar,
      buyer_name: registrar.name,
      buyer_reg_no: registrar.reg_no,
      buyer_country_code: registrar.address_country_code,
      buyer_state: registrar.address_state,
      buyer_street: registrar.address_street,
      buyer_city: registrar.address_city,
      buyer_zip: registrar.address_zip,
      buyer_phone: registrar.phone,
      buyer_url: registrar.website,
      buyer_email: registrar.email,
      reference_no: registrar.reference_no,
      vat_rate: vat_rate,
      monthly_invoice: true,
      metadata: { items: summary['invoice_lines'] },
      total: 0
    )
    return unless invoice.save!

    update_directo_number(num: invoice.number)
    invoice
  end

  def sync_with_directo
    invoices_xml = @directo_client.invoices.as_xml

    Rails.logger.info("[Directo] - attempting to send following XML:\n #{invoices_xml}")

    res = @directo_client.invoices.deliver(ssl_verify: false)
    process_directo_response(res.body, invoices_xml)
  rescue SocketError, Errno::ECONNREFUSED, Timeout::Error, Errno::EINVAL, Errno::ECONNRESET,
         EOFError, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError
    Rails.logger.info('[Directo] Failed to communicate via API')
  end

  def assign_monthly_numbers
    invoices_count = @directo_client.invoices.count
    last_directo_num = [Setting.directo_monthly_number_last.presence.try(:to_i),
                        @min_directo_num].compact.max || 0
    raise 'Directo Counter is out of period!' if directo_counter_exceedable?(invoices_count,
                                                                             last_directo_num)

    @directo_client.invoices.each do |inv|
      last_directo_num += 1
      inv.number = last_directo_num
    end
  end

  def assign_monthly_number
    last_directo_num = [Setting.directo_monthly_number_last.presence.try(:to_i),
                        @min_directo_num].compact.max || 0
    raise 'Directo Counter is out of period!' if directo_counter_exceedable?(1, last_directo_num)

    last_directo_num + 1
  end

  def directo_counter_exceedable?(invoices_count, last_directo_num)
    return true if @max_directo_num && @max_directo_num < (last_directo_num + invoices_count)

    false
  end

  def process_directo_response(body, req)
    Rails.logger.info "[Directo] - Responded with body: #{body}"
    Nokogiri::XML(body).css('Result').each do |res|
      inv = Invoice.find_by(number: res.attributes['docid'].value.to_i)
      mark_invoice_as_sent(res: res, req: req, invoice: inv)
    end
  end

  def mark_invoice_as_sent(res:, req:, invoice: nil)
    directo_record = Directo.new(response: res.as_json.to_h,
                                 request: req, invoice_number: res.attributes['docid'].value.to_i)
    directo_record.item = invoice
    invoice.update(in_directo: true)

    directo_record.save!
  end

  def update_directo_number(num:)
    return unless num.to_i > Setting.directo_monthly_number_last.to_i

    Setting.directo_monthly_number_last = num.to_i
  end
end
