class Client::DomainVersionsController < ClientController
  before_action :set_version, only: [:show]

  def index
    @versions = DomainVersion.registrar_events(current_registrar.id)
    @versions.flatten!
  end

  def show
    @event = params[:event]
    @domain = @version.reify(has_multiple: true) unless @event == 'create'
  end

  private

  def set_version
    @version = DomainVersion.find(params[:id])
  end
end
