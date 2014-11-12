class Admin::ZonefilesController < ApplicationController
  # TODO: Refactor this
  # rubocop:disable Metrics/MethodLength
  def index
    zf = Zonefile.new

    zf.origin = 'ee.'
    zf.ttl = '43200'

    zf.soa[:primary_ns] = 'ns.tld.ee.'
    zf.soa[:email] = 'hostmaster.eestiinternet.ee.'
    zf.soa[:origin] = 'ee.'
    zf.soa[:refresh] = '3600'
    zf.soa[:retry] = '900'
    zf.soa[:expire] = '1209600'
    zf.soa[:minimumTTL] = '3600'
    zf.new_serial

    zf.ns << { name: 'ee.', class: 'IN', host: 'b.tld.ee.' }
    zf.ns << { name: 'ee.', class: 'IN', host: 'e.tld.ee.' }
    zf.ns << { name: 'ee.', class: 'IN', host: 'ee.aso.ee.' }
    zf.ns << { name: 'ee.', class: 'IN', host: 'ns.ut.ee.' }
    zf.ns << { name: 'ee.', class: 'IN', host: 'ns.tld.ee.' }
    zf.ns << { name: 'ee.', class: 'IN', host: 'sunic.sunet.se.' }

    zf.a << { name: 'b.tld.ee.', class: 'IN', host: '194.146.106.110' }
    zf.a4 << { name: 'b.tld.ee.', class: 'IN', host: '2001:67c:1010:28::53' }
    zf.a << { name: 'e.tld.ee.', class: 'IN', host: '204.61.216.36' }
    zf.a4 << { name: 'e.tld.ee.', class: 'IN', host: '2001:678:94:53::53' }
    zf.a << { name: 'ee.aso.ee.', class: 'IN', host: '213.184.51.122' }
    zf.a4 << { name: 'ee.aso.ee.', class: 'IN', host: '2a02:88:0:21::2' }
    zf.a << { name: 'ns.ut.ee.', class: 'IN', host: '193.40.5.99' }
    zf.a << { name: 'ns.tld.ee.', class: 'IN', host: '195.43.87.10' }
    zf.a << { name: 'sunic.sunet.se.', class: 'IN', host: '192.36.125.2' }
    zf.a4 << { name: 'sunic.sunet.se.', class: 'IN', host: '2001:6b0:7::2' }

    Nameserver.all.includes(:domain).each do |x|
      zf.ns << { name: "#{x.domain_name}.", class: 'IN', host: "#{x.hostname}." }
      zf.a << { name: "#{x.hostname}.", class: 'IN', host: x.ipv4 } if x.ipv4.present?
      zf.a4 << { name: "#{x.hostname}.", class: 'IN', host: x.ipv6 } if x.ipv6.present?
    end

    @zonefile = zf.generate
  end
end
