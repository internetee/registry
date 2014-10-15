class Client::DomainVersionsController < ClientController
  before_action :set_domain, only: [:show]

  def index
    @versions = DomainVersion.registrar_events(current_registrar.id)
    @versions.flatten!
  end

  def show
    @versions = @domain.versions.reverse
  end

  private

  def set_domain
    @domain = Domain.find(params[:id])
  end
end
