class Invoice < ActiveRecord::Base
  belongs_to :seller, class_name: 'Registrar'
  belongs_to :buyer, class_name: 'Registrar'
  has_many :invoice_items
  accepts_nested_attributes_for :invoice_items
end
