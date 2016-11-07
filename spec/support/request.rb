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
      return if route.route_params.empty?

      rows = [
        "| Field name | Required | Type | Allowed values | Description |",
        "| ---------- | -------- | ---- | -------------- | ----------- |"
      ]

      route.route_params.each do |name, desc|
        details = []
        details << "| #{name} "
        details << "| #{desc[:required]} "
        details << "| #{desc[:type]} "
        details << "| #{ranges_from_array(desc[:values])} "
        details << "| #{desc[:desc]} |"
        rows << details.join
      end

      pretty_table(rows).join("\n")
    end

    def pretty_table(rows)
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

    def ranges_from_array(a)
      return unless a
      ranges = a.sort.uniq.reduce([]) do |spans, n|
        return a if n.is_a?(String)
        if spans.empty? || spans.last.last != n - 1
          spans + [n..n]
        else
          spans[0..-2] + [spans.last.first..n]
        end
      end

      ranges
    end
  end
end

RSpec.configure do |c|
  c.include Request, type: :request
end
