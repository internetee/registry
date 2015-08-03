require 'rails_helper'

describe ZonefileSetting do
  it 'generates the zonefile' do
    ZonefileSetting.where({
      origin: 'ee',
      ttl: 43200,
      refresh: 3600,
      retry: 900,
      expire: 1209600,
      minimum_ttl: 3600,
      email: 'hostmaster.eestiinternet.ee',
      master_nameserver: 'ns.tld.ee'
    }).first_or_create!

    ZonefileSetting.where({
      origin: 'pri.ee',
      ttl: 43200,
      refresh: 3600,
      retry: 900,
      expire: 1209600,
      minimum_ttl: 3600,
      email: 'hostmaster.eestiinternet.ee',
      master_nameserver: 'ns.tld.ee'
    }).first_or_create!

    d = Fabricate(:domain_with_dnskeys, name: 'testpri.ee')
    d.nameservers << Nameserver.new({
      hostname: "ns.#{d.name}",
      ipv4: '123.123.123.123',
      ipv6: 'FE80:0000:0000:0000:0202:B3FF:FE1E:8329'
    })

    @zonefile = ActiveRecord::Base.connection.execute(
      "select generate_zonefile('ee')"
    )[0]['generate_zonefile']

    @zonefile.should_not be_blank
    @zonefile.scan(/^#{d.name}/).count.should == 5
    @zonefile.scan(/ns.#{d.name}/).count.should == 3
    @zonefile.scan('123.123.123.123').count.should == 1
    @zonefile.scan('FE80:0000:0000:0000:0202:B3FF:FE1E:8329').count.should == 1

    @zonefile = ActiveRecord::Base.connection.execute(
      "select generate_zonefile('pri.ee')"
    )[0]['generate_zonefile']

    @zonefile.should_not be_blank

    @zonefile.scan(/^#{d.name}/).count.should == 0
  end

  it 'does not create duplicate zones' do
    Fabricate(:zonefile_setting)
    expect { Fabricate(:zonefile_setting) }.to raise_error(ActiveRecord::RecordInvalid)
  end

  it 'does not allow deleting zone when it has existing domains' do
    zs = ZonefileSetting.where({
      origin: 'ee',
      ttl: 43200,
      refresh: 3600,
      retry: 900,
      expire: 1209600,
      minimum_ttl: 3600,
      email: 'hostmaster.eestiinternet.ee',
      master_nameserver: 'ns.tld.ee'
    }).first_or_create!

    d = Fabricate(:domain)

    zs.destroy.should == false

    zs.errors.full_messages.should match_array(["There are 1 domains in this zone"])
    ZonefileSetting.count.should == 1

    d.destroy
    zs.destroy

    ZonefileSetting.count.should == 0
  end
end
