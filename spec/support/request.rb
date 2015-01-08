module Request
  def get_with_auth(path, params, epp_user)
    get path, params, env_with_auth(epp_user)
  end

  def delete_with_auth(path, epp_user)
    delete path, params, env_with_auth(epp_user)
  end

  def post_with_auth(path, params, epp_user)
    post path, params, env_with_auth(epp_user)
  end

  def patch_with_auth(path, params, epp_user)
    patch path, params, env_with_auth(epp_user)
  end

  def env
    {
      'Accept' => 'application/json',
      'Content-Type' => 'application/json'
    }
  end

  def env_with_auth(epp_user)
    env.merge({
      'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials(
        epp_user.username, epp_user.password
      )
    })
  end
end

RSpec.configure do |c|
  c.include Request, type: :request
end
