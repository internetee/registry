class Admin::NameserversController < ApplicationController
  before_action :set_domain
  before_action :set_nameserver, only: [:edit, :update, :destroy]

  def new
    @domain = Domain.find(params[:domain_id])
    @nameserver = @domain.nameservers.build
  end

  def create
    @domain = Domain.find(params[:domain_id])

    unless @domain.can_add_nameserver?
      @nameserver = @domain.nameservers.build(nameserver_params)
      flash.now[:alert] = I18n.t('shared.failed_to_add_nameserver')
      render 'new' and return
    end

    @domain.nameservers.build(nameserver_params)

    if @domain.save
      flash[:notice] = I18n.t('shared.nameserver_added')
      redirect_to [:admin, @domain]
    else
      flash.now[:alert] = I18n.t('shared.failed_to_add_nameserver')
      render 'new'
    end
  end

  def edit
    @domain = Domain.find(params[:domain_id])
    @nameserver = Nameserver.find(params[:id])
  end

  def update
    if @nameserver.update(nameserver_params) && @domain.valid?
      redirect_to [:admin, @domain]
    else
      render 'edit'
    end
  end

  def destroy
    if @domain.can_remove_nameserver?
      if @nameserver.destroy
        flash[:notice] = I18n.t('shared.nameserver_deleted')
      else
        flash[:alert] = I18n.t('shared.failed_to_delete_nameserver')
      end
    else
      flash[:alert] = @domain.errors[:nameservers].first
    end

    redirect_to [:admin, @domain]
  end

  private

  def set_domain
    @domain = Domain.find(params[:domain_id])
  end

  def set_nameserver
    @nameserver = Nameserver.find(params[:id])
  end

  def nameserver_params
    params.require(:nameserver).permit(:hostname, :ipv4, :ipv6)
  end
end
