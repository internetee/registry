require 'rails_helper'

RSpec.describe Admin::DomainsController do
  describe 'routing' do
    it 'routes to #schedule_force_delete' do
      expect(patch: '/admin/domains/1/schedule_force_delete').to route_to('admin/domains#schedule_force_delete', id: '1')
    end

    it 'routes to #cancel_force_delete' do
      expect(patch: '/admin/domains/1/cancel_force_delete').to route_to('admin/domains#cancel_force_delete', id: '1')
    end
  end
end
