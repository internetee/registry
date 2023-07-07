module Admin
  class CertificatesController < BaseController
    load_and_authorize_resource
    before_action :set_certificate, :set_api_user, only: %i[sign show download_csr download_crt revoke destroy]

    def show; end

    def new
      @api_user = ApiUser.find(params[:api_user_id])
      @certificate = Certificate.new(api_user: @api_user)
    end

    def create
      @api_user = ApiUser.find(params[:api_user_id])

      crt = certificate_params[:crt].open.read if certificate_params[:crt]
      csr = certificate_params[:csr].open.read if certificate_params[:csr]

      @certificate = @api_user.certificates.build(csr: csr, crt: crt)
      if @api_user.save
        flash[:notice] = I18n.t('record_created')
        redirect_to [:admin, @api_user, @certificate]
      else
        flash.now[:alert] = I18n.t('failed_to_create_record')
        render 'new'
      end
    end

    def destroy
      success = @certificate.revokable? ? revoke_and_destroy_certificate : @certificate.destroy

      if success
        flash[:notice] = I18n.t('record_deleted')
        redirect_to admin_registrar_api_user_path(@api_user.registrar, @api_user)
      else
        flash.now[:alert] = I18n.t('failed_to_delete_record')
        render 'show'
      end
    end

    def sign
      if @certificate.sign!(password: certificate_params[:password])
        flash[:notice] = I18n.t('record_updated')
        notify_registrar
        redirect_to [:admin, @api_user, @certificate]
      else
        flash.now[:alert] = I18n.t('failed_to_update_record')
        render 'show'
      end
    end

    def revoke
      if @certificate.revoke!(password: certificate_params[:password])
        flash[:notice] = I18n.t('record_updated')
      else
        flash[:alert] = I18n.t('failed_to_update_record')
      end
      redirect_to [:admin, @api_user, @certificate]
    end

    def download_csr
      filename = "#{@api_user.username}_#{Time.zone.today.strftime('%y%m%d')}_portal.csr.pem"
      send_data @certificate.csr, filename: filename
    end

    def download_crt
      filename = "#{@api_user.username}_#{Time.zone.today.strftime('%y%m%d')}_portal.crt.pem"
      send_data @certificate.crt, filename: filename
    end

    private

    def set_certificate
      @certificate = Certificate.find(params[:id])
      @csr = OpenSSL::X509::Request.new(@certificate.csr) if @certificate.csr
      @crt = OpenSSL::X509::Certificate.new(@certificate.crt) if @certificate.crt
    end

    def set_api_user
      @api_user = ApiUser.find(params[:api_user_id])
    end

    def certificate_params
      if params[:certificate]
        params.require(:certificate).permit(:crt, :csr, :password)
      else
        {}
      end
    end

    def notify_registrar
      email = @api_user.registrar.email

      CertificateMailer.signed(email: email, api_user: @api_user,
                               crt: OpenSSL::X509::Certificate.new(@certificate.crt))
                       .deliver_now
    end

    def revoke_and_destroy_certificate
      @certificate.revoke!(password: certificate_params[:password]) && @certificate.destroy
    end
  end
end
