require 'rails_helper'

RSpec.describe Registrar::DomainsController do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/registrar/domains').to route_to('registrar/domains#index')
    end
  end
end
