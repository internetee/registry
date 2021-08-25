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

  class << self
    def types_for_select
      [CREATE, RENEW, ADD_CREDIT, UPDATE_CREDIT].map { |x| [I18n.t(x), x] }
    end

    def to_csv
      attributes = %w(description activity_type created_at sum)

      CSV.generate(headers: true) do |csv|
        csv << %w(registrar description activity_type receipt_date sum)

        all.each do |x|
          attrs  = [x.account.registrar.try(:code)]
          attrs += attributes.map { |attr| x.send(attr) }
          csv << attrs
        end
      end
    end
  end
end

