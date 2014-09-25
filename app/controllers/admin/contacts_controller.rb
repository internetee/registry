class Admin::ContactsController < AdminController
  # TODO created_by and updated_by ids
  before_action :set_contact, only: [:show, :destroy, :edit, :update]

  def index
    @q = Contact.search(params[:q])
    @contacts = @q.result.page(params[:page])
  end

  def new
    @contact = Contact.new
    @contact.build_local_address
    @contact.build_international_address
  end

  def create
    @contact = Contact.new(contact_params)
    @contact.generate_code
    if @contact.save
      flash[:notice] = I18n.t('shared.contact_added')
      redirect_to [:admin, @contact]
    else
      flash[:alert] = I18n.t('shared.failed_to_create_contact')
      render "new"
    end
  end

  def destroy
    if @contact.destroy_and_clean
      flash[:notice] = I18n.t('shared.contact_deleted')
      redirect_to admin_contacts_path
    else
      flash[:alert] = I18n.t('shared.failed_to_delete_contact')
      redirect_to [:admin, @contact]
    end
  end

  def update
    if @contact.update_attributes(contact_params)
      flash[:notice] = I18n.t('shared.contact_updated')
      redirect_to [:admin, @contact]
    else
      flash[:alert] = I18n.t('shared.failed_to_update_contact')
      redirect_to [:admin, @contact]
    end
  end

  def search
    render json: Contact.search_by_query(params[:q])
  end

  private

  def set_contact
    @contact = Contact.find(params[:id])
  end

  def contact_params
    params.require(:contact).permit( :email, :phone, :fax, :ident_type, :ident, :auth_info,
                                    local_address_attributes: [:city, :street, :zip, :street2, :street3, :name, :org_name, :country_id],
                                    international_address_attributes: [:city, :street, :zip, :street2, :street3, :name, :org_name, :country_id])
  end
end
