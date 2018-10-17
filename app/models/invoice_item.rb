class InvoiceItem < ActiveRecord::Base
  include Versions
  belongs_to :invoice

  def item_sum_without_vat
    (price * quantity).round(2)
  end
end
