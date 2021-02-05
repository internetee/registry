class Registrar
  class TechContactsController < BulkChangeController
    BASE_URL = URI.parse("#{ENV['repp_url']}domains/contacts").freeze
    ACTIVE_TAB = :technical_contact

    def update
      authorize! :manage, :repp

      uri = BASE_URL
      request = Net::HTTP::Patch.new(uri)
      request.set_form_data(current_contact_id: params[:current_contact_id],
                            new_contact_id: params[:new_contact_id])
      request.basic_auth(current_registrar_user.username,
                         current_registrar_user.plain_text_password)

      response = do_request(request, uri)

      start_notice = t('.replaced')

      process_response(response: response,
                       start_notice: start_notice,
                       active_tab: ACTIVE_TAB)
    end
  end
end
