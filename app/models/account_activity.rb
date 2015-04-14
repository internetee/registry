class AccountActivity < ActiveRecord::Base
  belongs_to :account
  belongs_to :bank_transaction
  belongs_to :invoice

  after_create :update_balance
  def update_balance
    account.balance += sum
    account.save
  end
end

