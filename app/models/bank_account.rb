class BankAccount
  include ActiveModel::Model

  attr_accessor :iban
  attr_accessor :swift
  attr_accessor :bank_name
end