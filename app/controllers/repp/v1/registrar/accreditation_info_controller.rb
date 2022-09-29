module Repp
  module V1
    module Registrar
      if Feature.allow_accr_endspoints?
        class AccreditationInfoController < BaseController
          api :GET, 'repp/v1/registrar/accreditation/get_info'
          desc 'check login user and return data'

          def index
            login = current_user
            registrar = current_user.registrar

            # rubocop:disable Style/AndOr
            render_success(data: nil) and return unless login
            # rubocop:enable Style/AndOr

            data = set_values_to_data(login: login, registrar: registrar)

            render_success(data: data)
          end

          private

          def set_values_to_data(login:, registrar:)
            data = login.as_json(only: %i[id
                                          username
                                          name
                                          uuid
                                          roles
                                          accreditation_date
                                          accreditation_expire_date])
            data[:registrar_name] = registrar.name
            data[:registrar_reg_no] = registrar.reg_no
            data
          end
        end
      end
    end
  end
end
