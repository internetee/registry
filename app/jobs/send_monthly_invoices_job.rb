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

  # rubocop:disable Metrics/MethodLength
  def send_monthly_invoices
    Registrar.with_cash_accounts.find_each do |registrar|
      summary = registrar.monthly_summary(month: @month)
      next if summary.nil?

      invoice = registrar.monthly_invoice(month: @month) || create_invoice(summary, registrar)
      next if invoice.nil? || @dry

      send_email_to_registrar(invoice: invoice, registrar: registrar)
      send_e_invoice(invoice.id)
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

  # rubocop:enable Metrics/MethodLength

  def send_email_to_registrar(invoice:, registrar:)
    InvoiceMailer.invoice_email(invoice: invoice,
                                recipient: registrar.billing_email)
                 .deliver_now
  end

  def send_e_invoice(invoice_id)
    SendEInvoiceJob.set(wait: 1.minute).perform_later(invoice_id, payable: false)
  end

  def create_invoice(summary, registrar)
    invoice = registrar.init_monthly_invoice(normalize(summary))
    invoice.number = assign_monthly_number
    return unless invoice.save!

    update_monthly_invoice_number(num: invoice.number)
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
      mark_invoice_as_sent_to_directo(res: res, req: req, invoice: inv)
    end
  end

  def mark_invoice_as_sent_to_directo(res:, req:, invoice: nil)
    directo_record = Directo.new(response: res.as_json.to_h,
                                 request: req, invoice_number: res.attributes['docid'].value.to_i)
    directo_record.item = invoice
    invoice.update(in_directo: true)

    directo_record.save!
  end

  def update_monthly_invoice_number(num:)
    return unless num.to_i > Setting.directo_monthly_number_last.to_i

    Setting.directo_monthly_number_last = num.to_i
  end

  private

  def normalize(summary, lines: [])
    sum = summary.dup
    line_map = Hash.new 0
    sum['invoice_lines'].each { |l| line_map[l] += 1 }

    line_map.each_key do |count|
      count['quantity'] = line_map[count] unless count['unit'].nil?
      regex = /Domeenide ettemaks|Domains prepayment/
      count['quantity'] = -1 if count['description'].match?(regex)
      lines << count
    end

    sum['invoice_lines'] = summarize_lines(lines)
    sum
  end

  def summarize_lines(invoice_lines, lines: [])
    line_map = Hash.new 0
    invoice_lines.each do |l|
      hash = l.with_indifferent_access.except(:start_date, :end_date)
      line_map[hash] += 1
    end

    line_map.each_key do |count|
      count['price'] = (line_map[count] * count['price'].to_f).round(3) unless count['price'].nil?
      lines << count
    end

    lines
  end
end
