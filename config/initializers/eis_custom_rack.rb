# EIS custom rack hack in order to enable test external interfaces EPP/REPP inside webserver network 
module Rack
  class Request
    def trusted_proxy?(ip)
      if ENV['eis_trusted_proxies']
        ENV['eis_trusted_proxies'].split(',').map(&:strip).include?(ip)
      else
        ip =~ /\A127\.0\.0\.1\Z|\A(10|172\.(1[6-9]|2[0-9]|30|31)|192\.168)\.|\A::1\Z|\Afd[0-9a-f]{2}:.+|\Alocalhost\Z|\Aunix\Z|\Aunix:/i
      end
    end
  end
end
