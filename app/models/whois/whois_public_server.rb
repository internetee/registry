class WhoisPublicServer < ActiveRecord::Base
  self.abstract_class = true
  establish_connection :"#{Rails.env}_public_whois"
end
