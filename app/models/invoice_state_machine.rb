# enum status: %i[unpaid paid cancelled failed]

class InvoiceStateMachine
  attr_reader :invoice, :status

  def initialize(invoice:, status:)
    @invoice = invoice
    @status = status.to_sym
  end

  def call
    case status
    when :paid
      mark_as_paid
    when :cancelled
      mark_as_cancel
    when :unpaid
      mark_as_unpaid
    else
      raise "Inavalid state #{invoice.status}"
    end
  end

  private

  def mark_as_paid
    raise "Inavalid state #{invoice.status}" unless invoice.unpaid? || invoice.paid?

    invoice.autobind_manually
  end

  def mark_as_cancel
    # Paid invoice cannot be cancelled?
    raise "Inavalid state #{invoice.status}" unless invoice.cancellable? || invoice.cancelled?

    invoice.cancel
  end

  def mark_as_unpaid
    raise "Inavalid state #{invoice.status}" unless invoice.paid? && invoice.payment_orders.present? || invoice.unpaid?

    invoice.cancel_manualy
  end
end
