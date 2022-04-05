class AccountActivity < ApplicationRecord
  include Versions
  belongs_to :account, required: true
  belongs_to :bank_transaction
  belongs_to :invoice
  belongs_to :price, class_name: 'Billing::Price'

  CREATE = 'create'.freeze
  RENEW = 'renew'.freeze
  ADD_CREDIT = 'add_credit'.freeze
  UPDATE_CREDIT = 'update_credit'.freeze

  after_create :update_balance

  def update_balance
    account.balance += sum
    account.save

    self.new_balance = account.balance
    save
  end

  def as_csv_row
    [account.registrar.try(:code), description, I18n.t(activity_type), I18n.l(created_at), sum]
  end

  class << self
    def types_for_select
      [CREATE, RENEW, ADD_CREDIT, UPDATE_CREDIT].map { |x| [I18n.t(x), x] }
    end

    def csv_header
      ['Registrar', 'Description', 'Activity Type', 'Receipt Date', 'Sum']
    end
  end
end
