require 'rails_helper'

RSpec.describe Registrant::DomainDeleteConfirmsController do
  describe 'routing' do
    it 'routes to #show' do
      expect(get: '/registrant/domain_delete_confirms/1').to route_to('registrant/domain_delete_confirms#show', id: '1')
    end
  end
end
