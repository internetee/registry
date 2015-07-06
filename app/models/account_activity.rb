class AccountActivity < ActiveRecord::Base
  include Versions
  belongs_to :account
  belongs_to :bank_transaction
  belongs_to :invoice

  CREATE = 'create'
  RENEW = 'renew'
  ADD_CREDIT = 'add_credit'

  after_create :update_balance
  def update_balance
    account.balance += sum
    account.save
  end
end

