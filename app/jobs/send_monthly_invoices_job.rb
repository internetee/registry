class SendMonthlyInvoicesJob < ApplicationJob # rubocop:disable Metrics/ClassLength
  queue_as :default
  discard_on StandardError

  def perform(dry: false, months_ago: 1, overwrite: false)
    @dry = dry
    @overwrite = overwrite
    @month = Time.zone.now - months_ago.month
    @directo_data = []

    send_monthly_invoices
  end

  # rubocop:disable Metrics/MethodLength
  def send_monthly_invoices
    invoices = find_or_init_monthly_invoices
    assign_invoice_numbers(invoices)
    return if invoices.empty? || @dry

    invoices.each do |inv|
      inv.send_to_registrar! unless inv.sent?
      send_e_invoice(inv.id)
      @directo_data << inv.as_monthly_directo_json unless inv.in_directo
    end
    return if @directo_data.empty?

    EisBilling::SendDataToDirecto.send_request(object_data: @directo_data,
                                               monthly: true)
  end

  def assign_invoice_numbers(invoices)
    invoice_without_numbers = invoices.select { |i| i.number.nil? }
    return if invoice_without_numbers.empty?

    result = EisBilling::GetMonthlyInvoiceNumbers.send_request(invoice_without_numbers.size)
    response = JSON.parse(result.body)
    handle_assign_numbers_response_errors(response)

    numbers = response['invoice_numbers']
    invoice_without_numbers.each_with_index do |inv, index|
      inv.number = numbers[index]
      next if inv.save

      Rails.logger.info 'There was an error creating monthly ' \
        "invoice #{inv.number}: #{inv.errors.full_messages.first}"
    end
  end
  # rubocop:enable Metrics/MethodLength

  def find_or_init_monthly_invoices(invoices: [])
    Registrar.with_cash_accounts.find_each do |registrar|
      invoice = registrar.find_or_init_monthly_invoice(month: @month, overwrite: @overwrite)
      invoices << invoice unless invoice.nil?
    end
    invoices
  end

  def send_e_invoice(invoice_id)
    SendEInvoiceJob.set(wait: 30.seconds).perform_later(invoice_id, payable: false)
  end

  private

  def handle_assign_numbers_response_errors(response)
    raise 'INVOICE NUMBER LIMIT REACHED, COULD NOT GENERATE INVOICE' if response['code'] == '403'
    raise 'PROBLEM WITH TOKEN' if response['error'] == 'out of range'
  end
end
