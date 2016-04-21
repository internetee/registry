require 'rails_helper'

feature 'ReservedDomain', type: :feature do
  before :all do
    Fabricate(:zonefile_setting, origin: 'ee')
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

    click_link "New"
    fill_in 'Name',     with: "110.ee"
    fill_in 'Password', with: "testpw"
    click_button 'Save'


    ReservedDomain.pluck(:name).should include("110.ee")
    ReservedDomain.pw_for("110.ee").should == "testpw"

    d.valid?.should == false
    d.errors.full_messages.should match_array(
      ["Required parameter missing; reserved>pw element required for reserved domains"]
    )

    d.reserved_pw = 'wrongpw'
    d.valid?.should == false

    d.reserved_pw = 'testpw'
    d.valid?.should == true
    d.errors.full_messages.should match_array([])

    d.save
    visit admin_reserved_domains_url
    page.should have_content('110.ee')
    page.should_not have_content('testpw')
  end
end
