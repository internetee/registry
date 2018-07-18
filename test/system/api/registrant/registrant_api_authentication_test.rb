require 'test_helper'

class RegistrantApiAuthenticationTest < ApplicationSystemTestCase
  def setup
    super

  end

  def teardown
    super

  end

  def test_request_creates_user_when_one_does_not_exist
    params = {
      ident: "30110100103",
      first_name: "Jan",
      last_name: "Tamm",
      country: "ee",
    }

    post '/api/v1/registrant/auth/eid', params
  end
end
