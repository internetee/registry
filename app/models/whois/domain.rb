module Whois
  class Domain < Whois::Server
    self.table_name = 'domains'
  end
end
