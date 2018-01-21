module Repp
  class DomainTransfersV1 < Grape::API
    version 'v1', using: :path

    resource :domain_transfers do
      post '/' do
        params['domainTransfers'].each do |domain_transfer|
          domain_name = domain_transfer['domainName']
          transfer_code = domain_transfer['transferCode']
          new_registrar = current_user.registrar

          domain = Domain.find_by(name: domain_name)
          domain.transfer(registrar: new_registrar, transfer_code: transfer_code)
        end
      end
    end
  end
end
