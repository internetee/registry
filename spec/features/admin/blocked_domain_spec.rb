require 'rails_helper'

feature 'BlockedDomain', type: :feature do
  before :all do
    Fabricate(:zonefile_setting, origin: 'ee')
    @user = Fabricate(:admin_user)
  end

  before do
    sign_in @user
  end

  it 'should manage blocked domains' do
    visit admin_blocked_domains_url
    page.should have_content('Blocked domains')

    d = Fabricate.build(:domain, name: 'ftp.ee')
    d.valid?
    d.errors.full_messages.should match_array([])

    domains = %w(ftp.ee cache.ee)
    domains.each do |domain|
      click_link "New"
      fill_in 'Name', with: domain
      click_button 'Save'
    end


    BlockedDomain.pluck(:name).should include(*domains)

    d.valid?
    d.errors.full_messages.should match_array(["Data management policy violation: Domain name is blocked [name]"])
  end
end
