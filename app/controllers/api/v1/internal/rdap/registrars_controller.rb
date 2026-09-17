module Api
  module V1
    module Internal
      module Rdap
        class RegistrarsController < BaseController
          # Narrow entity shape: {code, name, phone, website} only.
          # email and reg_no MUST NOT appear here (they live only inside the
          # domain payload, §1.4).
          def show
            registrar = Registrar.find_by(code: params[:code].to_s.upcase)

            if registrar
              render json: {
                code: registrar.code,
                name: registrar.name,
                phone: registrar.phone,
                website: registrar.website,
              }, status: :ok
            else
              render_error('Registrar not found', :not_found)
            end
          end
        end
      end
    end
  end
end
