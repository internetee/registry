class OverdueInvoiceCanceller
  attr_reader :invoices
  attr_reader :delay

  def initialize(invoices: Invoice.overdue, delay: self.class.delay)
    @invoices = invoices
    @delay = delay
  end

  def self.default_delay
    30.days
  end

  def self.delay
    Setting.days_to_keep_overdue_invoices_active&.days || default_delay
  end

  def cancel
    invoices.each do |invoice|
      next unless cancellable?(invoice)

      invoice.cancel
      yield invoice if block_given?
    end
  end

  private

  def cancellable?(invoice)
    due_date_with_delay = invoice.due_date + delay
    due_date_with_delay.past?
  end
end