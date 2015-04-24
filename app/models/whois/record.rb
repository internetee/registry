module Whois
  class Record < Whois::Server
    self.table_name = 'whois_records'
  end
end
