require 'rails_helper'

RSpec.describe Registrar::SessionsController do
  describe 'routing' do
    it 'routes to #login' do
      expect(get: '/registrar/login').to route_to('registrar/sessions#login')
    end
  end
end
