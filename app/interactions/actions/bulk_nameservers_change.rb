module Actions
  class BulkNameserversChange
    def initialize(params, domains, current_registrar_user, options = {})
      @params = params
      @domains = domains
      @current_registrar_user = current_registrar_user
      @ipv4 = options.fetch(:ipv4)
      @ipv6 = options.fetch(:ipv6)
      @uri = options.fetch(:uri)
    end

    def call
      request = Net::HTTP::Put.new(@uri, 'Content-Type' => 'application/json')
      request.body = { data: { type: 'nameserver', id: @params[:old_hostname],
                               domains: @domains || [],
                               attributes: { hostname: @params[:new_hostname],
                                             ipv4: @ipv4,
                                             ipv6: @ipv6 } } }.to_json
      request.basic_auth(@current_registrar_user.username,
                         @current_registrar_user.plain_text_password)

      action = Actions::DoRequest.new(request, @uri)
      action.call
    end
  end
end
