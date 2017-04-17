require 'rails_helper'

RSpec.describe Admin::ReservedDomainsController do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/admin/reserved_domains').to route_to('admin/reserved_domains#index')
    end

    it 'does not route to #show' do
      expect(get: '/admin/reserved_domains/1').not_to be_routable
    end

    it 'routes to #new' do
      expect(get: '/admin/reserved_domains/new').to route_to('admin/reserved_domains#new')
    end

    it 'routes to #create' do
      expect(post: '/admin/reserved_domains').to route_to('admin/reserved_domains#create')
    end

    it 'routes to #edit' do
      expect(get: '/admin/reserved_domains/1/edit').to route_to('admin/reserved_domains#edit', id: '1')
    end

    it 'routes to #update' do
      expect(patch: '/admin/reserved_domains/1').to route_to('admin/reserved_domains#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/admin/reserved_domains/1').to route_to('admin/reserved_domains#destroy', id: '1')
    end
  end
end
