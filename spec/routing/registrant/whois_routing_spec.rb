require 'rails_helper'

RSpec.describe Registrant::WhoisController do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/registrant/whois').to route_to('registrant/whois#index')
    end
  end
end
