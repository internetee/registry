require 'serializers/repp/api_user'
module Repp
  module V1
    class ApiUsersController < BaseController
      before_action :find_api_user, only: %i[show update destroy verify download_poi approve_verification reject_verification]
      load_and_authorize_resource

      THROTTLED_ACTIONS = %i[index show create update destroy verify download_poi approve_verification reject_verification].freeze
      include Shunter::Integration::Throttle

      api :GET, '/repp/v1/api_users'
      desc 'Get all api users'
      def index
        users = current_user.registrar.api_users

        render_success(data: { users: serialized_users(users),
                               count: users.count })
      end

      api :GET, '/repp/v1/api_users/:id'
      desc 'Get a specific api user'
      def show
        serializer = Serializers::Repp::ApiUser.new(@api_user)
        render_success(data: { user: serializer.to_json, roles: ApiUser::ROLES })
      end

      api :POST, '/repp/v1/api_users'
      desc 'Create a new api user'
      def create
        @api_user = current_user.registrar.api_users.build(api_user_params)
        @api_user.active = api_user_params[:active]
        unless @api_user.save
          handle_non_epp_errors(@api_user)
          return
        end

        render_success(data: { api_user: { id: @api_user.id } })
      end

      api :PUT, '/repp/v1/api_users/:id'
      desc 'Update api user'
      def update
        unless @api_user.update(api_user_params)
          handle_non_epp_errors(@api_user)
          return
        end

        render_success(data: { api_user: { id: @api_user.id } })
      end

      api :DELETE, '/repp/v1/api_users/:id'
      desc 'Delete a specific api user'
      def destroy
        unless @api_user.destroy
          handle_non_epp_errors(@api_user)
          return
        end

        render_success
      end

      api :POST, '/repp/v1/api_users/verify/:id'
      desc 'Generate and send identification request to an api user'
      def verify
        authorize! :verify, ApiUser
        action = Actions::ApiUserVerify.new(@api_user)

        unless action.call
          handle_non_epp_errors(@api_user)
          return
        end

        render_success(data: { api_user: { id: @api_user.id } })
      end

      api :GET, '/repp/v1/api_users/download_poi/:id'
      desc 'Get proof of identity pdf file for an api user'
      def download_poi
        authorize! :verify, ApiUser
        ident_service = Eeid::IdentificationService.new('priv')
        response = ident_service.get_proof_of_identity(@api_user.verification_id)

        send_data response[:data], filename: "proof_of_identity_#{@api_user.verification_id}.pdf",
                                   type: 'application/pdf', disposition: 'inline'
      rescue Eeid::IdentError => e
        handle_non_epp_errors(@api_user, e.message)
      end

      api :POST, '/repp/v1/api_users/approve_verification/:id'
      desc 'Manually approve pending api user identification'
      def approve_verification
        authorize! :verify, ApiUser
        action = Actions::ApiUserApproveVerification.new(
          @api_user,
          subject: approve_verification_params[:subject]
        )

        unless action.call
          handle_non_epp_errors(@api_user)
          return
        end

        render_success(data: { api_user: { id: @api_user.id } })
      end

      api :POST, '/repp/v1/api_users/reject_verification/:id'
      desc 'Reject pending api user identification'
      def reject_verification
        authorize! :verify, ApiUser
        action = Actions::ApiUserRejectVerification.new(@api_user)

        unless action.call
          handle_non_epp_errors(@api_user)
          return
        end

        render_success(data: { api_user: { id: @api_user.id } })
      end

      private

      def find_api_user
        @api_user = current_user.registrar.api_users.find(params[:id])
      end

      def api_user_params
        params.require(:api_user).permit(:username, :plain_text_password, :active,
                                         :subject, :email, { roles: [] })
      end

      def approve_verification_params
        params.fetch(:api_user, {}).permit(:subject)
      end

      def serialized_users(users)
        users.map { |i| Serializers::Repp::ApiUser.new(i).to_json }
      end
    end
  end
end
