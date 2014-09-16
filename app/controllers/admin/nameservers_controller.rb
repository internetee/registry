class Admin::NameserversController < ApplicationController
  before_action :set_domain
  before_action :set_nameserver, only: [:edit, :update, :destroy]

  def new
    @nameserver = @domain.nameservers.build
  end

  def create
    @domain.adding_nameserver = true
    @nameserver = @domain.nameservers.build(nameserver_params)

    if @domain.save
      flash[:notice] = I18n.t('shared.nameserver_added')
      redirect_to [:admin, @domain]
    else
      flash.now[:alert] = I18n.t('shared.failed_to_add_nameserver')
      render 'new'
    end
  end

  def edit
    @nameserver = Nameserver.find(params[:id])
  end

  def update
    if @nameserver.update(nameserver_params)
      redirect_to [:admin, @domain]
    else
      render 'edit'
    end
  end

  def destroy
    @domain.deleting_nameserver = true
    @domain.nameservers.select { |x| x == @nameserver }[0].mark_for_destruction

    if @domain.save
      flash[:notice] = I18n.t('shared.nameserver_deleted')
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
