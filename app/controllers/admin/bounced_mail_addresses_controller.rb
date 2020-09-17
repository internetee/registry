module Admin
  class BouncedMailAddressesController < BaseController
    before_action :set_bounced_mail_address, only: %i[show edit update destroy]
    load_and_authorize_resource

    # GET /bounced_mail_addresses
    def index
      @bounced_mail_addresses = BouncedMailAddress.all
    end

    # GET /bounced_mail_addresses/1
    def show; end

    # GET /bounced_mail_addresses/new
    def new
      @bounced_mail_address = BouncedMailAddress.new
    end

    # GET /bounced_mail_addresses/1/edit
    def edit; end

    # POST /bounced_mail_addresses
    def create
      @bounced_mail_address = BouncedMailAddress.new(bounced_mail_address_params)

      if @bounced_mail_address.save
        redirect_to(
          admin_bounced_mail_addresses_url,
          notice: 'Bounced mail address was successfully created.'
        )
      else
        render(:new)
      end
    end

    # PATCH/PUT /bounced_mail_addresses/1
    def update
      if @bounced_mail_address.update(bounced_mail_address_params)
        redirect_to(@bounced_mail_address, notice: 'Bounced mail address was successfully updated.')
      else
        render(:edit)
      end
    end

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

    # Only allow a trusted parameter "white list" through.
    def bounced_mail_address_params
      params.require(:bounced_mail_address).permit(
        :email,
        :bounce_reason,
        :incidents,
        :response_json
      )
    end
  end
end
