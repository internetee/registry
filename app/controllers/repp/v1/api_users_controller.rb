require 'serializers/repp/api_user'
module Repp
  module V1
    class ApiUsersController < BaseController
      load_and_authorize_resource

      THROTTLED_ACTIONS = %i[index show create update destroy].freeze
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

      private

      def api_user_params
        params.require(:api_user).permit(:username, :plain_text_password, :active,
                                         :identity_code, { roles: [] })
      end

      def serialized_users(users)
        users.map { |i| Serializers::Repp::ApiUser.new(i).to_json }
      end
    end
  end
end
