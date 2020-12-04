module Repp
  module V1
    class AccountsController < BaseController
      def balance
        resp = { balance: current_user.registrar.cash_account.balance,
                 currency: current_user.registrar.cash_account.currency }
        render_success(data: resp)
      end
    end
  end
end
