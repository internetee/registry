module Repp
  module V1
    module Registrar
      class AccreditationResultsController < ActionController::API
        before_action :authenticate_shared_key

        TEMPORARY_SECRET_KEY = ENV['accreditation_secret'].freeze

        api :POST, 'repp/v1/registrar/accreditation/push_results'
        desc 'added datetime results'

        def create
          username = params[:accreditation_result][:username]
          result = params[:accreditation_result][:result]

          record_accreditation_result(username, result) if result
        rescue ActiveRecord::RecordNotFound
          record_not_found(username)
        end

        private

        def record_accreditation_result(username, result)
          user = ApiUser.find_by(username: username)

          raise ActiveRecord::RecordNotFound if user.nil?

          user.accreditation_date = DateTime.current

          return unless user.save

          render_success(data: { user: user,
                                 result: result,
                                 message: 'Accreditation info successfully added' })
        end

        def authenticate_shared_key
          api_key = "Basic #{TEMPORARY_SECRET_KEY}"
          render_failed unless api_key == request.authorization
        end

        def record_not_found(username)
          @response = { code: 2303, message: "Object '#{username}' does not exist" }
          render(json: @response)
        end

        def render_failed
          @response = { code: 2202, message: 'Invalid authorization information' }
          render(json: @response, status: :unauthorized)
        end

        def render_success(code: nil, message: nil, data: nil)
          @response = { code: code || 1000, message: message || 'Command completed successfully',
                        data: data || {} }

          render(json: @response, status: :ok)
        end
      end
    end
  end
end
