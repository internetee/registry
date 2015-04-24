class Admin::CertificatesController < AdminController
  load_and_authorize_resource
  before_action :set_certificate, :set_api_user, only: [:sign, :show, :download_csr, :download_crt, :revoke]

  def show
    @csr = OpenSSL::X509::Request.new(@certificate.csr) if @certificate.csr
    @crt = OpenSSL::X509::Certificate.new(@certificate.crt) if @certificate.crt
  end

  def new
    set_api_user
    @certificate = Certificate.new
  end

  def create
    @api_user = ApiUser.find(params[:api_user_id])
    csr = certificate_params[:csr].open.read if certificate_params[:csr]

    @certificate = @api_user.certificates.build(csr: csr)
    if @api_user.save
      flash[:notice] = I18n.t('record_created')
      redirect_to [:admin, @api_user, @certificate]
    else
      flash.now[:alert] = I18n.t('failed_to_create_record')
      render 'new'
    end
  end

  def sign
    if @certificate.sign!
      flash[:notice] = I18n.t('record_updated')
      redirect_to [:admin, @api_user, @certificate]
    else
      flash.now[:alert] = I18n.t('failed_to_update_record')
      render 'show'
    end
  end

  def revoke
    if @certificate.revoke!
      flash[:notice] = I18n.t('record_updated')
    else
      flash[:alert] = I18n.t('failed_to_update_record')
    end
    redirect_to [:admin, @api_user, @certificate]
  end

  def download_csr
    send_data @certificate.csr, filename: "#{@api_user.username}.csr.pem"
  end

  def download_crt
    send_data @certificate.crt, filename: "#{@api_user.username}.crt.pem"
  end

  private

  def set_certificate
    @certificate = Certificate.find(params[:id])
  end

  def set_api_user
    @api_user = ApiUser.find(params[:api_user_id])
  end

  def certificate_params
    params.require(:certificate).permit(:csr)
  end
end
