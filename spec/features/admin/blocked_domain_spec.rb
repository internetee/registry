require 'rails_helper'

feature 'BlockedDomain', type: :feature do
  before :all do
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

    fill_in 'blocked_domains', with: "ftp.ee\ncache.ee"
    click_button 'Save'

    page.should have_content('Record updated')
    page.should have_content('ftp.ee')
    page.should have_content('cache.ee')

    d.valid?
    d.errors.full_messages.should match_array(["Domain name Domain name is blocked"])
  end
end
