module Whois
  class Server < ApplicationRecord
    self.abstract_class = true
    establish_connection :"whois_#{Rails.env}"
  end
end
