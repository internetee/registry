class Client::DomainTransfersController < ClientController
  before_action :set_domain_transfer, only: [:show, :approve]
  before_action :set_domain, only: [:create]

  def index
    @q = current_registrar.domain_transfers.search(params[:q])
    @q.sorts = 'created_at desc' if @q.sorts.empty?
    @domain_transfers = @q.result.page(params[:page])
  end

  def new
    @domain_transfer = DomainTransfer.new
  end

  # rubocop: disable Metrics/PerceivedComplexity
  # rubocop: disable Metrics/CyclomaticComplexity
  def create
    @domain_transfer = @domain.pending_transfer

    if @domain_transfer
      if can? :read, @domain_transfer
        flash[:notice] = I18n.t('shared.domain_transfer_requested') if @domain.registrar != current_registrar
        redirect_to [:client, @domain_transfer] and return
      else
        flash.now[:alert] = I18n.t('shared.other_registrar_has_already_requested_to_transfer_this_domain')
        render 'new' and return
      end
    end

    @domain_transfer = @domain.domain_transfers.create(domain_transfer_params)
    @domain_transfer.approve_as_server if SettingGroup.domain_general.setting(:transfer_wait_time).value.to_i == 0

    if @domain_transfer.approved?
      flash[:notice] = I18n.t('shared.domain_transfer_approved')
      redirect_to [:client, @domain_transfer]
    else
      flash[:notice] = I18n.t('shared.domain_transfer_requested')
      redirect_to [:client, @domain_transfer]
    end
  end
  # rubocop: enable Metrics/PerceivedComplexity
  # rubocop: enable Metrics/CyclomaticComplexity

  def approve
    if can? :approve_as_client, @domain_transfer
      @domain_transfer.approve_as_client
      flash[:notice] = I18n.t('shared.domain_transfer_approved')
    else
      flash[:alert] = I18n.t('shared.failed_to_approve_domain_transfer')
    end

    redirect_to [:client, @domain_transfer]
  end

  private

  def set_domain_transfer
    @domain_transfer = DomainTransfer.find(params[:id])
  end

  def domain_transfer_params
    {
      status: DomainTransfer::PENDING,
      transfer_requested_at: Time.zone.now,
      transfer_to: current_registrar,
      transfer_from: @domain.registrar
    }
  end

  # rubocop: disable Metrics/PerceivedComplexity
  # rubocop: disable Metrics/CyclomaticComplexity
  def set_domain
    @domain_transfer = DomainTransfer.new
    @domain = Domain.find_by(name: params[:domain_name])
    if @domain
      if @domain.auth_info != params[:domain_pw]
        flash.now[:alert] = I18n.t('shared.password_invalid')
        render 'new' and return
      end

      if @domain.registrar == current_registrar && !@domain.pending_transfer
        flash.now[:alert] = I18n.t('shared.domain_already_belongs_to_the_querying_registrar')
        render 'new' and return
      end
    else
      flash.now[:alert] = I18n.t('shared.domain_was_not_found')
      render 'new'
    end
  end
  # rubocop: enbale Metrics/PerceivedComplexity
  # rubocop: enable Metrics/CyclomaticComplexity
end
