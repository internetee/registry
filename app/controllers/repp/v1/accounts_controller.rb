module Repp
  module V1
    class AccountsController < BaseController
      def balance
        return activity if params[:detailed] == 'true'

        resp = { balance: current_user.registrar.cash_account.balance,
                 currency: current_user.registrar.cash_account.currency }
        render_success(data: resp)
      end

      def activity
        resp = { balance: current_user.registrar.cash_account.balance,
                 currency: current_user.registrar.cash_account.currency }
        resp[:activities] = activities
        render_success(data: resp)
      end

      def activities
        bal = current_user.registrar.cash_account.balance
        act = []
        activities = current_user.registrar.cash_account.activities.order(created_at: :desc)
        activities.each do |a|
          act << {
            created_at: a.created_at,
            description: a.description,
            type: a.activity_type == 'add_credit' ? 'credit' : 'debit',
            sum: a.sum,
            balance: bal,
          }

          bal = a.activity_type == 'add_credit' ? bal = bal + a.sum : bal - a.sum
        end

        act
      end
    end
  end
end
