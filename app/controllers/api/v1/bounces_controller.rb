module Api
  module V1
    class BouncesController < BaseController
      before_action :authenticate

      def create
        bounced_mail_address = BouncedMailAddress.record(json)
        bounced_mail_address ? render(head: :ok) : render(head: :failed)
      end
    end
  end
end
