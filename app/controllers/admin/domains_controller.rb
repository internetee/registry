class Admin::DomainsController < ApplicationController
  before_action :set_domain, only: [:show, :edit, :update, :destroy]
  before_action :verify_deletion, only: [:destroy]

  def new
    @domain = Domain.new
  end

  def create
    @domain = Domain.new(domain_params)

    if @domain.save
      redirect_to [:admin, @domain]
    else
      render 'new'
    end
  end

  def index
    @q = Domain.search(params[:q])
    @domains = @q.result.page(params[:page])
  end

  def show
    @domain.all_dependencies_valid?
  end

  def edit
    params[:registrar] = @domain.registrar
    params[:owner_contact] = @domain.owner_contact_code
  end

  def update
    if @domain.update(domain_params)
      redirect_to [:admin, @domain]
    else
      render 'edit'
    end
  end

  def destroy
    if @domain.destroy
      flash[:notice] = I18n.t('shared.domain_deleted')
      redirect_to admin_domains_path
    else
      flash[:alert] = I18n.t('shared.failed_to_delete_domain')
      redirect_to [:admin, @domain]
    end
  end

  private

  def set_domain
    @domain = Domain.find(params[:id])
  end

  def domain_params
    params.require(:domain).permit(:name, :period, :period_unit, :registrar_id, :owner_contact_id)
  end

  def verify_deletion
    return if @domain.can_be_deleted?
    flash[:alert] = I18n.t('shared.domain_status_prohibits_deleting')
    redirect_to [:admin, @domain]
  end
end

