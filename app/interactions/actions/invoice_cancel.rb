module Actions
  class InvoiceCancel
    attr_reader :invoice

    def initialize(invoice)
      @invoice = invoice
    end

    def call
      return false unless @invoice.can_be_cancelled?

      @invoice.update(cancelled_at: Time.zone.now)
    end
  end
end
