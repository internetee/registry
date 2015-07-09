require 'rails_helper'

feature 'ReservedDomain', type: :feature do
  before :all do
    @user = Fabricate(:admin_user)
  end

  before do
    sign_in @user
  end

  it 'should manage reserved domains' do
    visit admin_reserved_domains_url
    page.should have_content('Reserved domains')

    d = Fabricate.build(:domain, name: '110.ee')
    d.valid?
    d.errors.full_messages.should match_array([])

    fill_in 'reserved_domains', with: "110.ee: testpw"
    click_button 'Save'

    page.should have_content('Record updated')
    page.should have_content('110.ee: testpw')

    d.valid?.should == false
    d.errors.full_messages.should match_array(["Domain is reserved and requires correct auth info"])

    d.auth_info = 'testpw'
    d.valid?.should == true
    d.errors.full_messages.should match_array([])
  end
end
