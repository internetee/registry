class ReppApi
  def self.bulk_renew(domains, period, registrar)
    payload = { domains: domains, renew_period: period }
    token = Base64.urlsafe_encode64("#{registrar.username}:#{registrar.plain_text_password}")
    headers = { Authorization: "Basic #{token}" }

    RestClient.post("#{ENV['repp_url']}domains/renew/bulk", payload, headers)
  rescue RestClient::ExceptionWithResponse => e
    e.response
  end
end
