class Admin::ContactsController < AdminController
  load_and_authorize_resource
  before_action :set_contact, only: [:show]

  def index
    params[:q] ||= {}
    @q = Contact.includes(:registrar).search(params[:q])
    @contacts = @q.result.page(params[:page])

    if params[:statuses_contains]
      contacts = Contact.includes(:registrar).where(
        "contacts.statuses @> ?::varchar[]", "{#{params[:statuses_contains].join(',')}}"
      )
    else
      contacts = Contact.includes(:registrar)
    end

    normalize_search_parameters do
      @q = contacts.search(params[:q])
      @contacts = @q.result.page(params[:page])
    end

    @contacts = @contacts.per(params[:results_per_page]) if params[:results_per_page].to_i > 0
  end

  def search
    render json: Contact.search_by_query(params[:q])
  end

  def edit
  end

  def update
    cp = ignore_empty_statuses

    if @contact.update(cp)
      flash[:notice] = I18n.t('contact_updated')
      redirect_to [:admin, @contact]
    else
      flash.now[:alert] = I18n.t('failed_to_update_contact')
      render 'edit'
    end
  end

  private

  def set_contact
    @contact = Contact.includes(domains: :registrar).find(params[:id])
  end

  def contact_params
    if params[:contact]
      params.require(:contact).permit({ statuses: [], status_notes_array: [] })
    else
      { statuses: [] }
    end
  end

  def ignore_empty_statuses
    dp = contact_params
    dp[:statuses].reject!(&:blank?)
    dp
  end

  def normalize_search_parameters
    ca_cache = params[:q][:created_at_lteq]
    begin
      end_time = params[:q][:created_at_lteq].try(:to_date)
      params[:q][:created_at_lteq] = end_time.try(:end_of_day)
    rescue
      logger.warn('Invalid date')
    end

    yield

    params[:q][:created_at_lteq] = ca_cache
  end
end
