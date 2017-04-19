require 'rails_helper'

RSpec.describe Registrar::DomainsController, db: true do
  describe '#index' do
    before do
      sign_in_to_registrar_area
    end

    it 'responds with success' do
      csv_presenter = instance_double(Registrar::DomainListCSVPresenter, to_s: 'csv')
      expect(Registrar::DomainListCSVPresenter).to receive(:new).and_return(csv_presenter)

      get registrar_domains_url(format: 'csv')

      expect(response.body).to eq('csv')
    end

    it 'returns csv' do
      get registrar_domains_url(format: 'csv')

      expect(response).to have_http_status(:success)
    end
  end
end
