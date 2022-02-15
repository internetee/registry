class DirectoInvoiceForwardTwoJob < ApplicationJob
  def perform(monthly: false, dry: false)
    data = nil

    if monthly
      @month = Time.zone.now - 1.month
      data = collect_monthly_data
    else
      data = collect_receipts_data
    end

    EisBilling::SendDataToDirecto.send_request(object_data: data, monthly: monthly, dry: dry)
  end

  def collect_receipts_data
    unsent_invoices = Invoice.where(in_directo: false).non_cancelled
    collected_data = []

    unsent_invoices.each do |invoice|
      unless valid_invoice_conditions?(invoice)
        Rails.logger.info "[DIRECTO] Invoice #{invoice.number} has been skipped"
        next
      end
      collected_data << invoice.as_directo_json
    end

    collected_data
  end

  def valid_invoice_conditions?(invoice)
    if invoice.account_activity.nil? || invoice.account_activity.bank_transaction.nil? ||
       invoice.account_activity.bank_transaction.sum.nil? ||
       invoice.account_activity.bank_transaction.sum != invoice.total
      return false

    end

    true
  end

  def collect_monthly_data
    registrars_data = []

    Registrar.where.not(test_registrar: true).find_each do |registrar| 
      registrars_data << { 
        registrar: registrar,
        registrar_summery: registrar.monthly_summary(month: @month)
      }
    end

    registrars_data
  end

  def mark_invoice_as_sent(invoice: nil, res:, req:)
    directo_record = Directo.new(response: res.as_json.to_h,
                                 request: req, invoice_number: res.attributes['docid'].value.to_i)
    if invoice
      directo_record.item = invoice
      invoice.update(in_directo: true)
    else
      update_directo_number(num: directo_record.invoice_number)
    end

    directo_record.save!
  end

  def update_directo_number(num:)
    return unless num.to_i > Setting.directo_monthly_number_last.to_i

    Setting.directo_monthly_number_last = num.to_i
  end

  def directo_counter_exceedable?(invoice_count)
    min_directo    = Setting.directo_monthly_number_min.presence.try(:to_i)
    max_directo    = Setting.directo_monthly_number_max.presence.try(:to_i)
    last_directo   = [Setting.directo_monthly_number_last.presence.try(:to_i),
                      min_directo].compact.max || 0

    return true if max_directo && max_directo < (last_directo + invoice_count)

    false
  end
end
