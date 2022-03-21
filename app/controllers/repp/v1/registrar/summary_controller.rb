module Repp
  module V1
    module Registrar
      class SummaryController < BaseController
        api :GET, 'repp/v1/registrar/summary'
        desc 'check user summary info and return data'

        def index
          registrar = current_user.registrar

          data = evaluate_data(registrar: registrar)

          render_success(data: data)
        end

        private

        def evaluate_data(registrar:)
          data = current_user.as_json(only: %i[id username])
          data[:registrar_name] = registrar.name
          data[:last_login_date] = last_login_date
          data[:balance] = { amount: registrar.cash_account&.balance,
                             currency: registrar.cash_account&.currency }
          data[:domains] = registrar.domains.count
          data[:contacts] = registrar.contacts.count
          data[:phone] = registrar.phone
          data[:email] = registrar.email
          data[:billing_email] = registrar.billing_email
          data[:billing_address] = registrar.address
          data
        end

        def last_login_date
          q = ApiLog::ReppLog.ransack({ request_path_eq: '/repp/v1/registrar/auth',
                                        response_code_eq: '200',
                                        api_user_name_cont: current_user.username,
                                        request_method_eq: 'GET' })
          q.sorts = 'id desc'
          q.result.offset(1).first&.created_at
        end
      end
    end
  end
end