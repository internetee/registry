class Registrar
  class ContactsController < DeppController
    before_action :init_epp_contact
    helper_method :address_processing?
    helper_method :ident_types

    def index
      authorize! :view, Depp::Contact

      params[:q] ||= {}
      params[:q].delete_if { |_k, v| v.blank? }

      search_params = params[:q].deep_dup

      if search_params[:domain_contacts_type_in].is_a?(Array) && search_params[:domain_contacts_type_in].delete('registrant')
        search_params[:registrant_domains_id_not_null] = 1
      end

      if search_params.length == 1 && search_params[:name_matches].present?
        @contacts = Contact.find_by(name: search_params[:name_matches])
      end

      if params[:statuses_contains]
        contacts = current_registrar_user.registrar.contacts.includes(:registrar).where(
          "contacts.statuses @> ?::varchar[]", "{#{params[:statuses_contains].join(',')}}"
        )
      else
        contacts = current_registrar_user.registrar.contacts.includes(:registrar)
      end

      normalize_search_parameters do
        @q = contacts.search(search_params)
      end

      contacts = @q.result

      respond_to do |format|
        format.html do
          contacts_per_page = params[:results_per_page].to_i
          @contacts = contacts.page(params[:page])
          @contacts = @contacts.per(contacts_per_page) if contacts_per_page.positive?
        end
        format.csv do
          raw_csv = contacts.to_csv
          send_data raw_csv, filename: 'contacts.csv', type: "#{Mime[:csv]}; charset=utf-8"
        end
        format.pdf do
          view = ActionView::Base.new(ActionController::Base.view_paths, contacts: contacts)
          view.class_eval { include ::ApplicationHelper }
          raw_html = view.render(file: 'registrar/contacts/list_pdf', layout: false)
          raw_pdf = contacts.pdf(raw_html)

          send_data raw_pdf, filename: 'contacts.pdf'
        end
      end
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
      @contact = Depp::Contact.new(params[:depp_contact])

      if @contact.save
        redirect_to registrar_contact_url(@contact.id)
      else
        render 'new'
      end
    end

    def update
      authorize! :edit, Depp::Contact
      @contact = Depp::Contact.new(params[:depp_contact])

      if @contact.update_attributes(params[:depp_contact])
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
      @contact = Depp::Contact.new(params[:depp_contact])

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

    def normalize_search_parameters
      ca_cache = params[:q][:valid_to_lteq]
      begin
        end_time = params[:q][:valid_to_lteq].try(:to_date)
        params[:q][:valid_to_lteq] = end_time.try(:end_of_day)
      rescue
        logger.warn('Invalid date')
      end

      yield

      params[:q][:valid_to_lteq] = ca_cache
    end

    def address_processing?
      Contact.address_processing?
    end

    def ident_types
      Contact::Ident.types
    end
  end
end
