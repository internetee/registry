Fabricator(:zonefile_setting) do
  origin 'ee'
  ttl 43200
  refresh 3600
  expire 1209600
  minimum_ttl 3600
  email 'hostmaster.eestiinternet.ee'
  master_nameserver 'ns.tld.ee'
  after_build { |x| x.retry = 900 }
end
