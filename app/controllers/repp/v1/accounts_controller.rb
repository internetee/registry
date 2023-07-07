module Repp
  module V1
    class AccountsController < BaseController # rubocop:disable Metrics/ClassLength
      load_and_authorize_resource

      THROTTLED_ACTIONS = %i[
        index balance details update_auto_reload_balance disable_auto_reload_balance switch_user update
      ].freeze
      include Shunter::Integration::Throttle

      api :get, '/repp/v1/accounts'
      desc 'Get all activities'
      def index
        records = current_user.registrar.cash_account.activities

        q = records.ransack(PartialSearchFormatter.format(search_params))
        q.sorts = 'created_at desc' if q.sorts.empty?
        activities = q.result(distinct: true)

        limited_activities = activities.limit(limit).offset(offset)
                                       .includes(:invoice)

        render_success(data: { activities: serialized_activities(limited_activities),
                               count: activities.count,
                               types_for_select: AccountActivity.types_for_select })
      end

      # rubocop:disable Metrics/MethodLength
      api :get, '/repp/v1/accounts/details'
      desc 'Get current registrar account details'
      def details
        registrar = current_user.registrar
        type = registrar.settings['balance_auto_reload']&.dig('type')
        resp = { account: { billing_email: registrar.billing_email,
                            iban: registrar.iban,
                            iban_max_length: Iban.max_length,
                            linked_users: serialized_users(current_user.linked_users),
                            api_users: serialized_users(current_user.api_users),
                            white_ips: serialized_ips(registrar.white_ips),
                            balance_auto_reload: type,
                            min_deposit: Setting.minimum_deposit },
                 roles: ApiUser::ROLES,
                 interfaces: WhiteIp::INTERFACES }
        render_success(data: resp)
      end
      # rubocop:enable Metrics/MethodLength

      api :put, '/repp/v1/accounts'
      desc 'Update current registrar account details'
      def update
        registrar = current_user.registrar
        unless registrar.update(account_params)
          handle_non_epp_errors(registrar)
          return
        end

        render_success(data: { account: account_params },
                       message: I18n.t('registrar.account.update.saved'))
      end

      api :post, '/repp/v1/accounts/update_auto_reload_balance'
      desc 'Enable current registrar balance auto reload'
      def update_auto_reload_balance
        type = BalanceAutoReloadTypes::Threshold.new(type_params)
        unless type.valid?
          handle_non_epp_errors(type)
          return
        end

        settings = { balance_auto_reload: { type: type.as_json } }
        current_user.registrar.update!(settings: settings)
        render_success(data: { settings: settings },
                       message: I18n.t('registrar.settings.balance_auto_reload.update.saved'))
      end

      api :get, '/repp/v1/accounts/disable_auto_reload_balance'
      desc 'Disable current registrar balance auto reload'
      def disable_auto_reload_balance
        registrar = current_user.registrar
        registrar.settings.delete('balance_auto_reload')
        registrar.save!

        render_success(data: { settings: registrar.settings },
                       message: I18n.t('registrar.settings.balance_auto_reload.destroy.disabled'))
      end

      api :put, '/repp/v1/accounts/switch_user'
      desc 'Switch user to another api user'
      def switch_user
        new_user = ApiUser.find(account_params[:new_user_id])
        unless current_user.linked_with?(new_user)
          handle_non_epp_errors(new_user, 'Cannot switch to unlinked user')
          return
        end

        @current_user = new_user
        data = auth_values_to_data(registrar: current_user.registrar)
        message = I18n.t('registrar.current_user.switch.switched', new_user: new_user)
        token = Base64.urlsafe_encode64("#{new_user.username}:#{new_user.plain_text_password}")
        render_success(data: { token: token, registrar: data }, message: message)
      end

      api :get, '/repp/v1/accounts/balance'
      desc "Get account's balance"
      def balance
        resp = { balance: current_user.registrar.cash_account.balance,
                 currency: current_user.registrar.cash_account.currency }
        if params[:detailed] == 'true'
          activities = current_user.registrar.cash_account.activities.order(created_at: :desc)
          activities = activities.where('created_at >= ?', params[:from]) if params[:from]
          activities = activities.where('created_at <= ?', params[:until]) if params[:until]
          resp[:transactions] = serialized_activities(activities)
        end
        render_success(data: resp)
      end

      private

      def account_params
        params.require(:account).permit(:billing_email, :iban, :new_user_id)
      end

      def index_params
        params.permit(:id, :limit, :offset, :q,
                      :page, :per_page,
                      q: [:description_matches, :created_at_gteq,
                          :created_at_lteq, :s, { s: [] }, { activity_type_in: [] }])
      end

      def type_params
        permitted_params = params.require(:type).permit(:amount, :threshold)
        normalize_params(permitted_params)
      end

      def normalize_params(params)
        params[:amount] = params[:amount].to_f
        params[:threshold] = params[:threshold].to_f
        params
      end

      def search_params
        index_params.fetch(:q, {}) || {}
      end

      def limit
        index_params[:limit]
      end

      def offset
        index_params[:offset] || 0
      end

      def serialized_users(users)
        arr = []
        users.each do |u|
          arr << { id: u.id, username: u.username,
                   role: u.roles.first, registrar_name: u.registrar.name,
                   active: u.active }
        end

        arr
      end

      def serialized_activities(activities)
        arr = []
        activities.each do |a|
          arr << { created_at: a.created_at, description: a.description,
                   type: a.activity_type == 'add_credit' ? 'credit' : 'debit',
                   sum: a.sum, balance: a.new_balance, currency: a.currency,
                   updator: a.updator_str }
        end

        arr
      end

      def serialized_ips(ips)
        ips.as_json(only: %i[id ipv4 ipv6 interfaces committed])
      end
    end
  end
end
