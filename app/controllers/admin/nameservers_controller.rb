class Admin::NameserversController < ApplicationController
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

  def destroy
    # TODO: Refactor this
    @nameserver = Nameserver.find(params[:id])
    @domain = @nameserver.domains.first
    @nameserver.destroy
    redirect_to [:admin, @domain]
  end

  private

  def nameserver_params
    params.require(:nameserver).permit(:hostname, :ipv4, :ipv6)
  end
end
