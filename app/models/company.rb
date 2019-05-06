class Company
  include ActiveModel::Model

  attr_accessor :name
  attr_accessor :registration_number
  attr_accessor :vat_number
  attr_accessor :address
  attr_accessor :email
  attr_accessor :phone
  attr_accessor :website
end