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
    return push_error unless invoice.payable?
    return true if invoice.paid?

    invoice.autobind_manually
    invoice
  end

  def mark_as_cancel
    return push_error unless invoice.cancellable?
    return true if invoice.cancelled?

    invoice.cancel
    invoice
  end

  def mark_as_unpaid
    return push_error if invoice.paid? && invoice.payment_orders&.last&.payment_reference? || invoice.cancelled?
    return true unless invoice.paid?

    invoice.cancel_manualy
    invoice
  end

  def push_error
    invoice.errors.add(:base, "Inavalid state #{status}")

    false
  end
end
