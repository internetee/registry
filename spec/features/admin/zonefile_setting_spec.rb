require 'rails_helper'

feature 'Zonefile settings', type: :feature do
  before :all do
    @user = Fabricate(:admin_user)
  end

  context 'as unknown user' do
    it 'should redirect to login path' do
      visit admin_zonefile_settings_url

      current_path.should == '/admin/login'
    end
  end

  context 'as logged in user' do
    it 'should show index of contacts' do
      sign_in @user
      visit admin_zonefile_settings_url

      page.should have_content('Zonefile settings')
    end

    it 'should create zone' do
      sign_in @user
      visit admin_zonefile_settings_url

      page.should_not have_content('Generate zonefile')

      click_link 'New'
      fill_in 'Origin', with: 'ee'
      fill_in 'TTL', with: '43200'
      fill_in 'Refresh', with: '3600'
      fill_in 'Retry', with: '900'
      fill_in 'Expire', with: '1209600'
      fill_in 'Minimum TTL', with: '3600'
      fill_in 'E-Mail', with: 'hostmaster.eestiinternet.ee'
      fill_in 'Master nameserver', with: 'ns.tld.ee'
      fill_in('Ns records', with: '
        ee. IN NS sunic.sunet.se.
        ee. IN NS ns.eenet.ee.
        ee. IN NS ns.tld.ee.
        ee. IN NS ns.ut.ee.
        ee. IN NS e.tld.ee.
        ee. IN NS b.tld.ee.
        ee. IN NS ee.aso.ee.
      ')

      fill_in('A records', with: '
        ns.ut.ee. IN A 193.40.5.99
        ns.tld.ee. IN A 195.43.87.10
        ee.aso.ee. IN A 213.184.51.122
        b.tld.ee. IN A 194.146.106.110
        ns.eenet.ee. IN A 193.40.56.245
        e.tld.ee. IN A 204.61.216.36
      ')

      fill_in('AAAA records', with: '
        ee.aso.ee. IN AAAA 2A02:88:0:21::2
        b.tld.ee. IN AAAA 2001:67C:1010:28::53
        ns.eenet.ee. IN AAAA 2001:BB8::1
        e.tld.ee. IN AAAA 2001:678:94:53::53
      ')

      click_button 'Save'

      page.should have_content('Record created')
      page.should have_content('ee')
      page.should have_content('Generate zonefile')

      click_link 'Generate zonefile'
      response_headers['Content-Type'].should == 'text/plain'
      response_headers['Content-Disposition'].should == "attachment; filename=\"ee.txt\""
    end

    it 'does not delete zone with existin domains' do
      ZonefileSetting.find_by(origin: 'ee') || Fabricate(:zonefile_setting)
      Fabricate(:domain)
      sign_in @user
      visit admin_zonefile_settings_url
      click_link 'ee'
      click_link 'Delete'

      page.should have_content("There are 1 domains in this zone")
      page.should have_content('Failed to delete record')
    end

    it 'deletes a zone' do
      ZonefileSetting.find_by(origin: 'ee') || Fabricate(:zonefile_setting)
      Domain.destroy_all
      sign_in @user
      visit admin_zonefile_settings_url
      click_link 'ee'
      click_link 'Delete'
      page.should have_content('Record deleted')
      page.should_not have_content("Generate zonefile")
    end
  end
end
