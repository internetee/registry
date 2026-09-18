module Repp
  module V1
    module Registrar
      class AccreditationResultsController < BaseController
        before_action :authorize_accr_bot

        api :POST, 'repp/v1/registrar/accreditation/push_results'
        desc 'added datetime results'

        def create
          name = params[:accreditation_result][:registrar_name]
          last_theory_test_passed_at = params[:accreditation_result][:last_theory_test_passed_at]

          record_accreditation_result(name, last_theory_test_passed_at)
        rescue StandardError => e
          Rails.logger.error "Failed to record accreditation result for registrar '#{name}': #{e.message}"
          render(json: { code: 2304, message: e.message }, status: :unprocessable_entity)
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

        def record_accreditation_result(name, last_theory_test_passed_at)
          registrar = ::Registrar.find_by(name: name)
          raise ActiveRecord::RecordNotFound if registrar.nil?

          accreditation_date = parse_last_theory_test_passed_at(last_theory_test_passed_at)
          registrar.accreditation_date = accreditation_date
          expire_date = accreditation_date.nil? ? nil : accreditation_date + ENV.fetch('accr_expiry_months', 24).to_i.months
          registrar.accreditation_expire_date = expire_date

          data = {
            registrar_name: registrar.name,
            accreditation_date: registrar.accreditation_date,
            accreditation_expire_date: registrar.accreditation_expire_date
          }

          if registrar.save
            render_success(message: 'Accreditation info successfully added', data: data)
          else
            handle_non_epp_errors(registrar)
          end
        end

        def render_unauthorized(reason = 'Only accr_bot can update accreditation results')
          render(json: { code: 2202, message: reason }, status: :unauthorized)
        end

        def parse_last_theory_test_passed_at(value)
          return if value.blank?

          Time.zone.parse(value.to_s) || raise(ArgumentError, 'Invalid last_theory_test_passed_at')
        end
      end
    end
  end
end
