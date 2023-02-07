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
      push_error
    end
  end

  private

  def mark_as_paid
    return push_error unless invoice.payable? || invoice.paid?

    invoice.autobind_manually
    invoice
  end

  def mark_as_cancel
    return push_error unless invoice.cancellable? || invoice.cancelled?

    invoice.cancel
    invoice
  end

  def mark_as_unpaid
    return push_error if invoice.paid? || !invoice.cancellable?

    invoice.cancel_manualy
    invoice
  end

  def push_error
    invoice.errors.add(:base, "Inavalid state #{status}")

    false
  end
end
