require 'rails_helper'

feature 'Sessions', type: :feature do
  before :all do
    Fabricate(:zonefile_setting, origin: 'ee')
    @user = Fabricate(:ee_user)
    @registrar1 = Fabricate(:registrar1)
    @registrar2 = Fabricate(:registrar2)
    Fabricate.times(2, :domain, registrar: @registrar1)
    Fabricate.times(2, :domain, registrar: @registrar2)
  end

  scenario 'Admin logs in' do
    visit root_path

    sign_in @user
    page.should have_text('Welcome!')

    uri = URI.parse(current_url)
    uri.path.should == admin_domains_path

    page.should have_link('registrar1', count: 2)
    page.should have_link('registrar2', count: 2)
  end
end
