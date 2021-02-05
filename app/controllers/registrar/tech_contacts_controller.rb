class Registrar
  class TechContactsController < BulkChangeController
    BASE_URL = URI.parse("#{ENV['repp_url']}domains/contacts").freeze

    def update
      authorize! :manage, :repp

      uri = BASE_URL

      request = Net::HTTP::Patch.new(uri)
      request.set_form_data(current_contact_id: params[:current_contact_id],
                            new_contact_id: params[:new_contact_id])
      request.basic_auth(current_registrar_user.username,
                         current_registrar_user.plain_text_password)

      response = do_request(request, uri)

      parsed_response = JSON.parse(response.body, symbolize_names: true)

      if response.code == '200'
        notices = [t('.replaced')]

        notices << "#{t('.affected_domains')}: " \
                   "#{parsed_response[:data][:affected_domains].join(', ')}"

        if parsed_response[:data][:skipped_domains]
          notices << "#{t('.skipped_domains')}: " \
                     "#{parsed_response[:data][:skipped_domains].join(', ')}"
        end

        flash[:notice] = notices.join(', ')
        redirect_to registrar_domains_url
      else
        @error = response.code == '404' ? 'Contact(s) not found' : parsed_response[:message]
        render file: 'registrar/bulk_change/new', locals: { active_tab: :technical_contact }
      end
    end
  end
end
