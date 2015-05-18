require 'rails_helper'

feature 'Root', type: :feature do
  it 'should redirect to registrant login page' do
    visit '/registrant/login'
    current_path.should == '/registrant/login'
  end

  it 'should redirect to registrant login page' do
    visit '/registrant'
    current_path.should == '/registrant/login'
  end

  it 'should redirect to registrant login page' do
    visit '/registrant/'
    current_path.should == '/registrant/login'
  end
end
