require 'test_helper'

class ReserveTest < ApplicationIntegrationTest
  def setup
    super

  end

  def test_return_code_that_all_ok
    post '/api/v1/business_registry/reserve', params: { name: 'common.ee', organization_code: '12340' }
    json = JSON.parse(response.body, symbolize_names: true)

    puts(json)
  end
end
