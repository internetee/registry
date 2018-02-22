module Repp
  class DomainTransfersV1 < Grape::API
    version 'v1', using: :path

    resource :domain_transfers do
      post '/' do
        params do
          requires :data, type: Hash do
            requires :domainTransfers, type: Array do
              requires :domainName, type: String, allow_blank: false
              requires :transferCode, type: String, allow_blank: false
            end
          end
        end

        new_registrar = current_user.registrar
        domain_transfers = params['data']['domainTransfers']
        successful_domain_transfers = []
        errors = []

        domain_transfers.each do |domain_transfer|
          domain_name = domain_transfer['domainName']
          transfer_code = domain_transfer['transferCode']
          domain = Domain.find_by(name: domain_name)

          if domain
            if domain.transfer_code == transfer_code
              domain.transfer(new_registrar)
              successful_domain_transfers << { type: 'domain_transfer', attributes: { domain_name: domain.name } }
            else
              errors << { title: "#{domain_name} transfer code is wrong" }
            end
          else
            errors << { title: "#{domain_name} does not exist" }
          end
        end

        if errors.none?
          status 200
          @response = { data: successful_domain_transfers }
        else
          status 400
          @response = { errors: errors }
        end
      end
    end
  end
end
