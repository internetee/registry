module Admin
  class BouncedMailAddressesController < BaseController
    before_action :set_bounced_mail_address, only: %i[show destroy]
    load_and_authorize_resource

    # GET /bounced_mail_addresses
    def index
      @q = BouncedMailAddress.all.order(created_at: :desc).ransack(params[:q])
      @bounced_mail_addresses = @q.result.page(params[:page]).per(params[:results_per_page])
      @count = @q.result.count
    end

    # GET /bounced_mail_addresses/1
    def show; end

    # DELETE /bounced_mail_addresses/1
    def destroy
      @bounced_mail_address.destroy
      redirect_to(
        admin_bounced_mail_addresses_url,
        notice: 'Bounced mail address was successfully destroyed.'
      )
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_bounced_mail_address
      @bounced_mail_address = BouncedMailAddress.find(params[:id])
    end
  end
end
