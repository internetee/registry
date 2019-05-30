module Repp
  class AccountV1 < Grape::API
    version 'v1', using: :path

    resource :accounts do
      desc 'Return current cash account balance'

      get 'balance' do
        @response = {
          balance: current_user.registrar.cash_account.balance,
          currency: current_user.registrar.cash_account.currency,
        }
      end
    end
  end
end
