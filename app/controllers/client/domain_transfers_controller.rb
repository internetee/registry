class Client::DomainTransfersController < ClientController
  before_action :set_domain_transfer, only: :show
  before_action :set_domain, only: [:create]

  def new
    @domain_transfer = DomainTransfer.new
  end

  def create
    @domain_transfer = @domain.pending_transfer || @domain.domain_transfers.create(domain_transfer_params)
    if can? :read, @domain_transfer
      flash[:notice] = I18n.t('shared.domain_transfer_requested')
      redirect_to [:client, @domain_transfer]
    else
      flash[:alert] = I18n.t('shared.other_registrar_has_already_requested_to_transfer_this_domain')
      render 'new'
    end
  end

  private

  def set_domain_transfer
    @domain_transfer = DomainTransfer.find(params[:id])
  end

  def domain_transfer_params
    ret = {
      status: DomainTransfer::PENDING,
      transfer_requested_at: Time.zone.now,
      transfer_to: current_user.registrar,
      transfer_from: @domain.registrar
    }

    wait_time = SettingGroup.domain_general.setting(:transfer_wait_time).value.to_i

    if wait_time == 0
      ret[:status] = DomainTransfer::SERVER_APPROVED
      ret[:transferred_at] = Time.zone.now
    end

    ret
  end

  def set_domain
    @domain_transfer = DomainTransfer.new
    @domain = Domain.find_by(name: params[:domain_name])
    if @domain
      return if  @domain.auth_info == params[:domain_pw]
      flash[:alert] = I18n.t('shared.password_invalid')
      render 'new'
    else
      flash[:alert] = I18n.t('shared.domain_was_not_found')
      render 'new'
    end
  end
end
