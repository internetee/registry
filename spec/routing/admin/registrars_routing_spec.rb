require 'rails_helper'

RSpec.describe Admin::RegistrarsController do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/admin/registrars').to route_to('admin/registrars#index')
    end

    it 'routes to #new' do
      expect(get: '/admin/registrars/new').to route_to('admin/registrars#new')
    end

    it 'routes to #show' do
      expect(get: '/admin/registrars/1').to route_to('admin/registrars#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/admin/registrars/1/edit').to route_to('admin/registrars#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/admin/registrars').to route_to('admin/registrars#create')
    end

    it 'routes to #update' do
      expect(patch: '/admin/registrars/1').to route_to('admin/registrars#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/admin/registrars/1').to route_to('admin/registrars#destroy', id: '1')
    end
  end
end
