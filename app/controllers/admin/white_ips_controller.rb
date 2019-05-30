module Admin
  class WhiteIpsController < BaseController
    load_and_authorize_resource

    before_action :set_registrar, only: %i[new show edit destroy update]

    def new
      @white_ip = WhiteIp.new(registrar: @registrar)
    end

    def show; end

    def edit; end

    def destroy
      if @white_ip.destroy
        flash[:notice] = I18n.t('record_deleted')
        redirect_to admin_registrar_path(@registrar)
      else
        flash.now[:alert] = I18n.t('failed_to_delete_record')
        render 'show'
      end
    end

    def create
      @white_ip = WhiteIp.new(white_ip_params)
      @registrar = @white_ip.registrar

      if @white_ip.save
        flash[:notice] = I18n.t('record_created')
        redirect_to [:admin, @registrar, @white_ip]
      else
        flash.now[:alert] = I18n.t('failed_to_create_record')
        render 'new'
      end
    end

    def update
      if @white_ip.update(white_ip_params)
        flash[:notice] = I18n.t('record_updated')
        redirect_to [:admin, @registrar, @white_ip]
      else
        flash.now[:alert] = I18n.t('failed_to_update_record')
        render 'edit'
      end
    end

    private

    def set_registrar
      @registrar = Registrar.find_by(id: params[:registrar_id])
    end

    def white_ip_params
      params.require(:white_ip).permit(:ipv4, :ipv6, :registrar_id, interfaces: [])
    end
  end
end
