module Repp
  module V1
    module Registrar
      class AccreditationResultsController < BaseController
        before_action :check_feature_enabled, :authorize_accr_bot

        api :POST, 'repp/v1/registrar/accreditation/push_results'
        desc 'added datetime results'

        def create
          username = params[:accreditation_result][:username]
          result = params[:accreditation_result][:result]

          record_accreditation_result(username, result) if result
        end

        private

        def authorize_accr_bot
          accr_bot_username = ENV['accr_bot_username'] || 'accr_bot'
          return render_unauthorized unless @current_user&.username == accr_bot_username
          return if Rails.env.test? || Rails.env.development?

          validate_accr_bot_cert
        end

        def validate_accr_bot_cert
          # Validate client certificate CN and registration
          expected_cn = ENV['accr_bot_cert_cn'] || 'accr_bot'
          cert_cn = request.env['HTTP_SSL_CLIENT_S_DN_CN']
          cert_pem = request.env['HTTP_SSL_CLIENT_CERT']
          Rails.logger.debug "[validate_accr_bot_cert] cert_cn: #{cert_cn}"
          Rails.logger.debug "[validate_accr_bot_cert] expected_cn: #{expected_cn}"

          return render_unauthorized('Invalid certificate CN') unless cert_cn == expected_cn
          return if @current_user.pki_ok?(cert_pem, cert_cn, api: true)

          render_unauthorized('Certificate not registered')
        end

        def check_feature_enabled
          return if Feature.allow_accr_endspoints?

          render_unauthorized('Accreditation Center API is not enabled')
        end

        def record_accreditation_result(username, result)
          user = ApiUser.find_by(username: username)
          raise ActiveRecord::RecordNotFound if user.nil?

          user.accreditation_date = DateTime.current
          user.accreditation_expire_date = user.accreditation_date + ENV.fetch('accr_expiry_months', 24).to_i.months
 
          if user.save
            notify_registrar(user)
            notify_admins
            render_success(message: 'Accreditation info successfully added', data: { result: result })
          else
            handle_non_epp_errors(user)
          end
        end

        def notify_registrar(user)
          AccreditationCenterMailer.test_was_successfully_passed_registrar(user.registrar.email).deliver_now
        end

        def notify_admins
          admin_users_emails = User.all.reject { |u| u.roles.nil? }
                                   .select { |u| u.roles.include? 'admin' }.pluck(:email)

          admin_users_emails.compact!
          return if admin_users_emails.empty?

          admin_users_emails.each do |email|
            AccreditationCenterMailer.test_was_successfully_passed_admin(email).deliver_now
          end
        end

        def render_unauthorized(reason = 'Only accr_bot can update accreditation results')
          render(json: { code: 2202, message: reason }, status: :unauthorized)
        end
      end
    end
  end
end
