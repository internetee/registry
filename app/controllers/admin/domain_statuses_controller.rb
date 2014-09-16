class Admin::DomainStatusesController < ApplicationController
  before_action :set_domain
  before_action :set_domain_status, only: [:edit, :update, :destroy]

  def new
    @domain_status = @domain.domain_statuses.build(value: DomainStatus::OK)
  end

  def create
    @domain_status = @domain.domain_statuses.build(domain_status_params)

    if @domain.save
      flash[:notice] = I18n.t('shared.status_added')
      redirect_to [:admin, @domain]
    else
      flash.now[:alert] = I18n.t('shared.failed_to_add_status')
      render 'new'
    end
  end

  def edit; end

  def update
    if @domain_status.update(domain_status_params)
      flash[:notice] = I18n.t('shared.status_updated')
      redirect_to [:admin, @domain]
    else
      flash.now[:alert] = I18n.t('shared.failed_to_update_status')
      render 'edit'
    end
  end

  def destroy
    if @domain_status.destroy
      flash[:notice] = I18n.t('shared.status_deleted')
    else
      flash[:alert] = I18n.t('shared.failed_to_delete_status')
    end

    redirect_to [:admin, @domain]
  end

  private

  def set_domain
    @domain = Domain.find(params[:domain_id])
  end

  def set_domain_status
    @domain_status = DomainStatus.find(params[:id])
  end

  def domain_status_params
    params.require(:domain_status).permit(:value, :description)
  end
end
