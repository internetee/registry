module Whois
  class Server < ActiveRecord::Base
    self.abstract_class = true
    establish_connection :"whois_#{Rails.env}"
  end
end
