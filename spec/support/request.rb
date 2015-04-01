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

module Autodoc
  class Document
    def route_info_doc
      return unless example.metadata[:route_info_doc]
      route = request.env["rack.routing_args"][:route_info]
      return unless route.route_params.is_a?(Hash)

      params_details = [
        "| Field name | Required | Type | Allowed values |",
        "| ---------- | -------- | ---- | -------------- |"
      ]

      route.route_params.each do |name, desc|
        details = []
        details << "| #{name} "
        details << "| #{desc[:required]} "
        details << "| #{desc[:type]} "
        details << "| #{desc[:values]} |"
        params_details << details.join
        # required = desc.is_a?(Hash) ? desc[:required] : false
        # description = desc.is_a?(Hash) ? desc[:description] : desc.to_s
        # [name, required, "   * #{name}: #{description} #{required ? '(required)' : ''}"]
      end

      prettify_table(params_details).join("\n")
    end

    def prettify_table(rows)
      # longest_in_col = 0
      matrix_array = []
      rows.each do |x|
        matrix_array << x.split('|') + [''] # [''] is because split loses last |
      end

      new_arr = []
      matrix_array.transpose.each do |col|
        new_col = []
        longest = col.max_by(&:size).size

        col.each do |r|
          new_col << r.center(longest)
        end
        new_arr << new_col
      end

      matrix_array = []
      new_arr.transpose.each do |x|
        matrix_array << x.join('|')
      end

      matrix_array
    end
  end
end

RSpec.configure do |c|
  c.include Request, type: :request
end
