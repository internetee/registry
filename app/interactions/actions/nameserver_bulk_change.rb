module Actions
  class NameserverBulkChange
    def initialize(domains, params, ipv4, ipv6)
      @domains = domains
      @params = params
      @ipv4 = ipv4
      @ipv6 = ipv6
    end

    def call
      uri = URI.parse("#{ENV['repp_url']}registrar/nameservers")
      request = Net::HTTP::Put.new(uri, 'Content-Type' => 'application/json')
      request.body = { data: { type: 'nameserver', id: @params[:old_hostname],
                               domains: @domains || [],
                               attributes: { hostname: @params[:new_hostname],
                                             ipv4: ipv4,
                                             ipv6: ipv6 } } }.to_json
      request.basic_auth(current_registrar_user.username,
                         current_registrar_user.plain_text_password)

      response = do_request(request, uri)
    end
  end
end