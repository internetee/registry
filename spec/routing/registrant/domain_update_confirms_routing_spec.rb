require 'rails_helper'

RSpec.describe Registrant::DomainUpdateConfirmsController do
  describe 'routing' do
    it 'routes to #show' do
      expect(get: '/registrant/domain_update_confirms/1').to route_to('registrant/domain_update_confirms#show', id: '1')
    end
  end
end
