class Admin::CertificatesController < AdminController
  load_and_authorize_resource
  before_action :set_api_user, only: [:new, :show, :destroy, :edit, :update]

  def show; end

  def edit; end

  def new
    @certificate = Certificate.new(api_user: @api_user)
  end

  def create
    @api_user = ApiUser.find(params[:api_user_id])

    @certificate = @api_user.certificates.build(certificate_params)
    if @api_user.save
      flash[:notice] = I18n.t('record_created')
      redirect_to [:admin, @api_user, @certificate]
    else
      flash.now[:alert] = I18n.t('failed_to_create_record')
      render 'new'
    end
  end

  def update
    if @certificate.update(certificate_params)
      flash[:notice] = I18n.t('record_updated')
      redirect_to [:admin, @api_user, @certificate]
    else
      flash.now[:alert] = I18n.t('failed_to_update_record')
      render 'edit'
    end
  end

  def destroy
    if @certificate.destroy
      flash[:notice] = I18n.t('record_deleted')
      redirect_to admin_api_user_path(@api_user)
    else
      flash.now[:alert] = I18n.t('failed_to_delete_record')
      render 'show'
    end
  end

  # DEPRECATED FOR NOW
  # def sign
  #   if @certificate.sign!
  #     flash[:notice] = I18n.t('record_updated')
  #     redirect_to [:admin, @api_user, @certificate]
  #   else
  #     flash.now[:alert] = I18n.t('failed_to_update_record')
  #     render 'show'
  #   end
  # end

  # def revoke
  #   if @certificate.revoke!
  #     flash[:notice] = I18n.t('record_updated')
  #   else
  #     flash[:alert] = I18n.t('failed_to_update_record')
  #   end
  #   redirect_to [:admin, @api_user, @certificate]
  # end

  # def download_csr
  #   send_data @certificate.csr, filename: "#{@api_user.username}.csr.pem"
  # end

  # def download_crt
  #   send_data @certificate.crt, filename: "#{@api_user.username}.crt.pem"
  # end

  private

  # DEPRECATED FOR NOW
  # def set_certificate
  #   @certificate = Certificate.find(params[:id])
  #   @csr = OpenSSL::X509::Request.new(@certificate.csr) if @certificate.csr
  #   @crt = OpenSSL::X509::Certificate.new(@certificate.crt) if @certificate.crt
  # end

  def set_api_user
    @api_user = ApiUser.find(params[:api_user_id])
  end

  def certificate_params
    params.require(:certificate).permit(:common_name, :md5, :interface)
  end
end
