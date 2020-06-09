module Admin
  class ContactsController < BaseController
    load_and_authorize_resource
    before_action :set_contact, only: [:show]
    helper_method :ident_types
    helper_method :domain_filter_params

    def index
      params[:q] ||= {}
      search_params = params[:q].deep_dup

      if search_params[:domain_contacts_type_in].is_a?(Array) && search_params[:domain_contacts_type_in].delete('registrant')
        search_params[:registrant_domains_id_not_null] = 1
      end

      contacts = Contact.includes(:registrar).joins(:registrar)
                        .select('contacts.*, registrars.name')
      contacts = contacts.filter_by_states(params[:statuses_contains].join(',')) if params[:statuses_contains]
      contacts = filter_by_flags(contacts)

      normalize_search_parameters do
        @q = contacts.search(search_params)
        @contacts = @q.result.distinct.page(params[:page])
      end

      @contacts = @contacts.per(params[:results_per_page]) if params[:results_per_page].to_i.positive?
    end

    def filter_by_flags(contacts)
      if params[:only_no_country_code].eql?('1')
        contacts = contacts.where("ident_country_code is null or ident_country_code=''")
      end
      contacts = contacts.email_not_verified if params[:email_not_verified].eql?('1')
      contacts
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
      @contact = Contact.find(params[:id])
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
        # updated at
        end_time = params[:q][:updated_at_gteq].try(:to_date)
        params[:q][:updated_at_lteq] = end_time.try(:end_of_day)
      rescue
        logger.warn('Invalid date')
      end

      yield

      params[:q][:created_at_lteq] = ca_cache
    end

    def ident_types
      Contact::Ident.types
    end

    def domain_filter_params
      params.permit(:domain_filter)
    end
  end
end
