require 'rails_helper'

RSpec.describe Admin::DisputesController do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/admin/disputes').to route_to('admin/disputes#index')
    end

    it 'routes to #new' do
      expect(get: '/admin/disputes/new').to route_to('admin/disputes#new')
    end

    it 'routes to #create' do
      expect(post: '/admin/disputes').to route_to('admin/disputes#create')
    end

    it 'routes to #edit' do
      expect(get: '/admin/disputes/1/edit').to route_to('admin/disputes#edit', id: '1')
    end

    it 'routes to #update' do
      expect(patch: '/admin/disputes/1').to route_to('admin/disputes#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/admin/disputes/1').to route_to('admin/disputes#destroy', id: '1')
    end
  end
end
