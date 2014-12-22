module Whois
  class PrivateServer < ActiveRecord::Base
    self.abstract_class = true
    # establish_connection :"#{Rails.env}_private_whois"
  end
end
