class Admin::NameserversController < ApplicationController
  # TODO: Refactor this to domain_nameservers controller!
  before_action :set_domain
  before_action :set_nameserver, only: [:edit, :update, :destroy]

  def new
    @domain = Domain.find(params[:domain_id])
    @nameserver = @domain.nameservers.build
  end

  def create
    @domain = Domain.find(params[:domain_id])
    @nameserver = @domain.nameservers.build(nameserver_params)

    if @domain.save
      redirect_to [:admin, @domain]
    else
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
    # TODO: Refactor this
    @nameserver = Nameserver.find(params[:id])
    @domain = @nameserver.domains.first
    @nameserver.destroy
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
