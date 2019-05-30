class AccountActivity < ActiveRecord::Base
  include Versions
  belongs_to :account, required: true
  belongs_to :bank_transaction
  belongs_to :invoice
  belongs_to :price, class_name: 'Billing::Price'

  CREATE = 'create'.freeze
  RENEW = 'renew'.freeze
  ADD_CREDIT = 'add_credit'.freeze

  after_create :update_balance
  def update_balance
    account.balance += sum
    account.save
  end

  class << self
    def types_for_select
      [CREATE, RENEW, ADD_CREDIT].map { |x| [I18n.t(x), x] }
    end

    def to_csv
      attributes = %w[description activity_type created_at sum]

      CSV.generate(headers: true) do |csv|
        csv << %w[registrar description activity_type receipt_date sum]

        all.find_each do |x|
          attrs  = [x.account.registrar.try(:code)]
          attrs += attributes.map { |attr| x.send(attr) }
          csv << attrs
        end
      end
    end
  end
end

