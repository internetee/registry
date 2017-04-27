Fabricator(:zone, from: 'DNS::Zone') do
  origin 'ee'
  ttl 43200
  refresh 3600
  expire 1209600
  minimum_ttl 3600
  email 'hostmaster.eestiinternet.ee'
  master_nameserver 'ns.tld.ee'
  ns_records "ee. IN NS ns.ut.ee.\nee. IN NS ns.tld.ee.\nee. IN NS sunic.sunet.se.\n" \
             "ee. IN NS ee.aso.ee.\nee. IN NS b.tld.ee.\nee. IN NS ns.eenet.ee.\nee. IN NS e.tld.ee."
  a_records "ns.ut.ee. IN A 193.40.5.99\nns.tld.ee. IN A 195.43.87.10\nee.aso.ee. IN A 213.184.51.122\n" \
            "b.tld.ee. IN A 194.146.106.110\nns.eenet.ee. IN A 193.40.56.245\ne.tld.ee. IN A 204.61.216.36"
  a4_records "ee.aso.ee. IN AAAA 2a02:88:0:21::2\nb.tld.ee. IN AAAA 2001:67c:1010:28::53\n" \
             "ns.eenet.ee. IN AAAA 2001:bb8::1\ne.tld.ee. IN AAAA 2001:678:94:53::53"
  after_build { |x| x.retry = 900 }
end
