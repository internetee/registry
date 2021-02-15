module Repp
  module V1
    class AccountsController < BaseController
      def balance
        resp = { balance: current_user.registrar.cash_account.balance,
                 currency: current_user.registrar.cash_account.currency }
        resp[:activities] = activities if params[:detailed] == 'true'
        render_success(data: resp)
      end

      def activity
        resp = { balance: current_user.registrar.cash_account.balance,
                 currency: current_user.registrar.cash_account.currency }
        resp[:activities] = activities
        render_success(data: resp)
      end

      def activities
        activities = current_user.registrar.cash_account.activities.order(created_at: :desc)
        activities = activities.where('created_at >= ?', params[:from]) if params[:from]
        activities = activities.where('created_at <= ?', params[:until]) if params[:until]
        arr = []
        activities.each do |a|
          arr << {
            created_at: a.created_at,
            description: a.description,
            type: a.activity_type == 'add_credit' ? 'credit' : 'debit',
            sum: a.sum,
            balance: a.new_balance,
          }
        end

        arr
      end
    end
  end
end
