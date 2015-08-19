require 'rails_helper'

describe ZonefileSetting do
  it 'generates the zonefile' do
    Fabricate(:zonefile_setting)
    Fabricate(:zonefile_setting, origin: 'pri.ee')

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

    # origin ns
    @zonefile.scan(/ee. IN NS ns.ut.ee.\nee. IN NS ns.tld.ee./).count.should == 1
    # origin a
    @zonefile.scan(/ns.ut.ee. IN A 193.40.5.99\nns.tld.ee. IN A 195.43.87.10/).count.should == 1
    # origin aaaa
    @zonefile.scan(/ee.aso.ee. IN AAAA 2a02:88:0:21::2\nb.tld.ee. IN AAAA 2001:67c:1010:28::53/).count.should == 1

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

  it 'should not place serverHold nor clientHold domains into zonefile' do
    Fabricate(:zonefile_setting)
    d = Fabricate(:domain_with_dnskeys, 
                  name: 'testzone.ee', 
                  statuses: ['serverHold', 'serverDeleteProhibited', 'clientHold'])
    d.nameservers << Nameserver.new({
      hostname: "ns.#{d.name}",
      ipv4: '123.123.123.123',
      ipv6: 'FE80:0000:0000:0000:0202:B3FF:FE1E:8329'
    })

    @zonefile = ActiveRecord::Base.connection.execute(
      "select generate_zonefile('ee')"
    )[0]['generate_zonefile']

    @zonefile.should_not be_blank
    @zonefile.scan(/^#{d.name}/).count.should == 0
    @zonefile.scan(/ns.#{d.name}/).count.should == 0
    @zonefile.scan('123.123.123.123').count.should == 0
    @zonefile.scan('FE80:0000:0000:0000:0202:B3FF:FE1E:8329').count.should == 0

    d.statuses = ['clientHold', 'serverDeleteProhibited']
    d.save

    @zonefile = ActiveRecord::Base.connection.execute(
      "select generate_zonefile('ee')"
    )[0]['generate_zonefile']

    @zonefile.should_not be_blank
    @zonefile.scan(/^#{d.name}/).count.should == 0
    @zonefile.scan(/ns.#{d.name}/).count.should == 0
    @zonefile.scan('123.123.123.123').count.should == 0
    @zonefile.scan('FE80:0000:0000:0000:0202:B3FF:FE1E:8329').count.should == 0

    d.statuses = ['serverDeleteProhibited']
    d.save

    @zonefile = ActiveRecord::Base.connection.execute(
      "select generate_zonefile('ee')"
    )[0]['generate_zonefile']

    @zonefile.should_not be_blank
    @zonefile.scan(/^#{d.name}/).count.should == 5
    @zonefile.scan(/ns.#{d.name}/).count.should == 3
    @zonefile.scan('123.123.123.123').count.should == 1
    @zonefile.scan('FE80:0000:0000:0000:0202:B3FF:FE1E:8329').count.should == 1
  end

  it 'does not create duplicate zones' do
    Fabricate(:zonefile_setting)
    zs = Fabricate.build(:zonefile_setting)
    zs.save.should == false
    zs.errors.full_messages.should match_array(["Origin has already been taken"])
  end

  it 'does not allow deleting zone when it has existing domains' do
    zs = Fabricate(:zonefile_setting)

    d = Fabricate(:domain)

    zs.destroy.should == false

    zs.errors.full_messages.should match_array(["There are 1 domains in this zone"])
    ZonefileSetting.count.should == 1

    d.destroy
    zs.destroy

    ZonefileSetting.count.should == 0
  end
end
