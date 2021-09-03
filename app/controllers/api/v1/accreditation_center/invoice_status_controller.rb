module Api
  module V1
    module AccreditationCenter
      class InvoiceStatusController < ::Api::V1::AccreditationCenter::BaseController
        def index
          username, password = Base64.urlsafe_decode64(basic_token).split(':')
          @current_user ||= ApiUser.find_by(username: username, plain_text_password: password)

          return render json: { errors: 'No user found' }, status: :not_found if @current_user.nil?

          @invoices = @current_user.registrar.invoices.select { |i| i.cancelled_at != nil }

          if @invoices
            render json: { code: 1000, invoices: @invoices },
                   status: :found
          else
            render json: { errors: 'No invoices' }, status: :not_found
          end
        end

        private

        def basic_token
          pattern = /^Basic /
          header  = request.headers['Authorization']
          header = header.gsub(pattern, '') if header&.match(pattern)
          header.strip
        end
      end
    end
  end
end
