class DeleteMonthlyInvoicesJob < ApplicationJob
  queue_as :default

  def perform
    @month = Time.zone.now - 1.month
    invoices = Invoice.where(monthly_invoice: true, issue_date: @month.end_of_month.to_date,
                             in_directo: false, e_invoice_sent_at: nil)
    invoices.delete_all
  end
end
