class Registrar::InvoiceStatusPresenter
  include ActionView::Helpers::TagHelper

  attr_reader :invoice

  def initialize(invoice:)
    @invoice = invoice
  end

  def display
    case invoice.get_status_from_billing
    when 'unpaid'
      content_tag(:span, 'Unpaid', style: 'color: red;')
    when 'paid'
      content_tag(:span, 'Unpaid', style: 'color: red;')
    end
  end
end