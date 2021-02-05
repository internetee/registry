class Registrar
  class AdminContactsController < BulkChangeController
    BASE_URL = URI.parse("#{ENV['repp_url']}domains/admin_contacts").freeze
    ACTIVE_TAB = :admin_contact

    def update
      authorize! :manage, :repp

      uri = BASE_URL
      request = form_request(uri)
      response = do_request(request, uri)
      start_notice = t('.replaced')

      process_response(response: response,
                       start_notice: start_notice,
                       active_tab: ACTIVE_TAB)
    end
  end
end
