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

  def get_route_info(path)
    route = Repp::API.routes.select do |x|
      x.route_path.gsub('(.:format)', '').gsub(':version', x.route_version) == path
    end.first

    route_path = route.route_path.gsub('(.:format)', '').gsub(':version', route.route_version)

    puts "#{route.route_method} #{route_path}"
    puts " #{route.route_description}" if route.route_description

    if route.route_params.is_a?(Hash)
      params = route.route_params.map do |name, desc|
        required = desc.is_a?(Hash) ? desc[:required] : false
        description = desc.is_a?(Hash) ? desc[:description] : desc.to_s
        [name, required, "   * #{name}: #{description} #{required ? '(required)' : ''}"]
      end

      puts "  parameters:"
      params.each { |p| puts p[2] }
    end
  end
end

RSpec.configure do |c|
  c.include Request, type: :request
end
