class Registrar::ContactsController < Registrar::DeppController # EPP controller
  before_action :init_epp_contact

  def index
    authorize! :view, Depp::Contact
    limit, offset = pagination_details

    res = depp_current_user.repp_request('contacts', { details: true, limit: limit, offset: offset })
    flash.now[:epp_results] = [{ 'code' => res.code, 'msg' => res.message }]
    @response = res.parsed_body.with_indifferent_access if res.code == '200'
    @contacts    = @response ? @response[:contacts] : []

    @paginatable_array = Kaminari.paginate_array(
      [], total_count: @response[:total_number_of_records]
    ).page(params[:page]).per(limit)
  end

  def new
    authorize! :create, Depp::Contact
    @contact = Depp::Contact.new
  end

  def show
    authorize! :view, Depp::Contact
    @contact = Depp::Contact.find_by_id(params[:id])
  end

  def edit
    authorize! :edit, Depp::Contact
    @contact = Depp::Contact.find_by_id(params[:id])
  end

  def create
    authorize! :create, Depp::Contact
    @contact = Depp::Contact.new(params[:contact])

    if @contact.save
      redirect_to registrar_contact_url(@contact.id)
    else
      render 'new'
    end
  end

  def update
    authorize! :edit, Depp::Contact
    @contact = Depp::Contact.new(params[:contact])

    if @contact.update_attributes(params[:contact])
      redirect_to registrar_contact_url(@contact.id)
    else
      render 'edit'
    end
  end

  def delete
    authorize! :delete, Depp::Contact
    @contact = Depp::Contact.find_by_id(params[:id])
  end

  def destroy
    authorize! :delete, Depp::Contact
    @contact = Depp::Contact.new(params[:contact])

    if @contact.delete
      redirect_to registrar_contacts_url, notice: t(:destroyed)
    else
      render 'delete'
    end
  end

  private

  def init_epp_contact
    Depp::Contact.user = depp_current_user
  end
end
