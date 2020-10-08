module Repp
  module V1
    class AccountsController < BaseController
      def balance
        resp = { balance: current_user.registrar.cash_account.balance,
                 currency: current_user.registrar.cash_account.currency }
        render(json: resp, status: :ok)
      end
    end
  end
end
