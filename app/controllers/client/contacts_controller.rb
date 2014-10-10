class Client::ContactsController < ClientController
  before_action :set_contact, only: [:show, :destroy, :edit, :update]

  def index
    @q = Contact.current_registrars(current_registrar.id).search(params[:q])
    @contacts = @q.result.page(params[:page])
  end

  def new
    @contact = Contact.new
    @contact.build_address
  end

  def show
    # rubocop: disable Style/GuardClause
    if @contact.registrar != current_registrar
      flash[:alert] = I18n.t('shared.authentication_error')
      redirect_to client_contacts_path
    end
    # rubocop: enable Style/GuardClause
  end

  def create
    @contact = Contact.new(contact_params)
    @contact.generate_code
    @contact.registrar = current_registrar
    if @contact.save
      flash[:notice] = I18n.t('shared.contact_added')
      redirect_to [:client, @contact]
    else
      flash[:alert] = I18n.t('shared.failed_to_create_contact')
      render 'new'
    end
  end

  def destroy
    if @contact.destroy_and_clean
      flash[:notice] = I18n.t('shared.contact_deleted')
      redirect_to client_contacts_path
    else
      flash[:alert] = I18n.t('shared.failed_to_delete_contact')
      redirect_to [:client, @contact]
    end
  end

  def update
    if @contact.update_attributes(contact_params)
      flash[:notice] = I18n.t('shared.contact_updated')
      redirect_to [:client, @contact]
    else
      flash[:alert] = I18n.t('shared.failed_to_update_contact')
      redirect_to [:client, @contact]
    end
  end

  # TODO: Add Registrar to Contacts and search only contacts that belong to this domain
  def search
    render json: Contact.search_by_query(params[:q])
  end

  private

  def set_contact
    @contact = Contact.find(params[:id])
  end

  def contact_params
    params.require(:contact).permit(:email, :phone, :fax, :ident_type, :ident, :auth_info, :name, :org_name,
                                    address_attributes: [:city, :street, :zip, :street2, :street3, :country_id])
  end
end
