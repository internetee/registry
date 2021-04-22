module TransactionPaidInvoices
  extend ActiveSupport::Concern

  def invoice
    return unless registrar

    @invoice ||= registrar.invoices
                          .order(created_at: :asc)
                          .unpaid
                          .non_cancelled
                          .find_by(total: sum)
  end

  def non_canceled?
    paid_invoices = registrar.invoices
                             .order(created_at: :asc)
                             .non_cancelled
                             .where(total: sum)
    paid_invoices.any? do |invoice|
      return true if invoice.paid? && fresh_admin_paid_invoice(invoice)
    end
  end

  private

  def fresh_admin_paid_invoice(invoice)
    check_for_date_paid_invoice(invoice) && does_invoice_created_by_admin?(invoice)
  end

  def check_for_date_paid_invoice(invoice)
    invoice.account_activity.created_at > Time.zone.today - 2.days
  end

  def does_invoice_created_by_admin?(invoice)
    invoice.account_activity.creator_str&.include? 'Admin'
  end
end
