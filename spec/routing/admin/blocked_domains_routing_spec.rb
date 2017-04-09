require 'rails_helper'

RSpec.describe Admin::BlockedDomainsController do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/admin/blocked_domains').to route_to('admin/blocked_domains#index')
    end

    it 'does not route to #show' do
      expect(get: '/admin/blocked_domains/1').not_to be_routable
    end

    it 'routes to #new' do
      expect(get: '/admin/blocked_domains/new').to route_to('admin/blocked_domains#new')
    end

    it 'routes to #create' do
      expect(post: '/admin/blocked_domains').to route_to('admin/blocked_domains#create')
    end

    it 'does not route to #edit' do
      expect(get: '/admin/blocked_domains/1/edit').not_to be_routable
    end

    it 'does not route to #update' do
      expect(patch: '/admin/blocked_domains/1').not_to be_routable
    end

    it 'routes to #destroy' do
      expect(delete: '/admin/blocked_domains/1').to route_to('admin/blocked_domains#destroy', id: '1')
    end
  end
end
