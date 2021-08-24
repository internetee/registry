class Registrar
  class DomainTransfersController < BulkChangeController
    before_action do
      authorize! :transfer, Depp::Domain
    end

    def new
    end

    def create
      if params[:batch_file].present?
        csv = CSV.read(params[:batch_file].path, headers: true)
        domain_transfers = []

        csv.each do |row|
          domain_name = row['Domain']
          transfer_code = row['Transfer code']
          domain_transfers << { 'domain_name' => domain_name, 'transfer_code' => transfer_code }
        end

        uri = URI.parse("#{ENV['repp_url']}domains/transfer")
        request = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
        request.body = { data: { domain_transfers: domain_transfers } }.to_json
        request.basic_auth(current_registrar_user.username,
                           current_registrar_user.plain_text_password)

        action = Actions::DoRequest.new(request, uri)
        response = action.call

        parsed_response = JSON.parse(response.body, symbolize_names: true)

        if response.code == '200'
          failed = parsed_response[:data][:failed].pluck(:domain_name).join(', ')
          flash[:notice] = t('.transferred', count: parsed_response[:data][:success].size,
                                             failed: failed)
          redirect_to registrar_domains_url
        else
          @api_errors = parsed_response[:message]
          render 'registrar/bulk_change/new', locals: { active_tab: :bulk_transfer }
        end
      else
        params[:request] = true # EPP domain:transfer "op" attribute
        domain = Depp::Domain.new(current_user: depp_current_user)
        @data = domain.transfer(params)
        render :new unless response_ok?
      end
    end
  end
end
