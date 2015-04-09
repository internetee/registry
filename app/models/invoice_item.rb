class InvoiceItem < ActiveRecord::Base
  belongs_to :invoice

  def item_total_without_vat
    amount * price
  end
end
