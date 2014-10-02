class Client::ContactVersionsController < ClientController
  before_action :set_version, only: [:show]

  def index
    @versions = ContactVersion.registrar_events(current_user.registrar.id)
    @versions.flatten!
  end

  def show
    @event = params[:event]
    @contact = @version.reify(has_one: true) unless @event == 'create'
  end

  private

  def set_version
    @version = ContactVersion.find(params[:id])
  end
end
