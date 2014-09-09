class Admin::NameserversController < ApplicationController
  def new
    @domain = Domain.find_by(params[:id])
    @nameserver = @domain.nameservers.build
  end

  def create
    @domain = Domain.find(params[:domain_id])
    if @domain.nameservers.create(nameserver_params)
      redirect_to [:admin, @domain]
    else
      render 'new'
    end
  end

  private

  def nameserver_params
    params.require(:nameserver).permit(:hostname, :ipv4, :ipv6)
  end
end
