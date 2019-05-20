class InvoiceItem < ActiveRecord::Base
  include Versions
  belongs_to :invoice

  delegate :vat_rate, to: :invoice

  def item_sum_without_vat
    (price * quantity).round(2)
  end
  alias_method :subtotal, :item_sum_without_vat

  def vat_amount
    subtotal * (vat_rate / 100)
  end

  def total
    subtotal + vat_amount
  end
end