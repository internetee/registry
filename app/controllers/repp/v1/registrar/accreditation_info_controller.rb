module Repp
  module V1
    module Registrar
      class AccreditationInfoController < BaseController
        api :GET, 'repp/v1/registrar/accreditation/get_info'
        desc 'check login user and return data'

        def index
          @login = current_user
          registrar = current_user.registrar

          # name = registrar.name
          # reg_no = registrar.reg_no

          # rubocop:disable Style/AndOr
          render_success(data: nil) and return unless @login
          # rubocop:enable Style/AndOr

          data = @login.as_json(only: %i[id username name reg_no uuid roles accreditation_date accreditation_expire_date])
          data[:registrar_name] = registrar.name
          data[:registrar_reg_no] = registrar.reg_no

          render_success(data: data)
        end
      end
    end
  end
end
