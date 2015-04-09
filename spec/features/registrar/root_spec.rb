require 'rails_helper'

feature 'Root', type: :feature do
  before :all do
    create_settings
    Fabricate(:api_user)
  end

  fit 'should redirect to registrar login page' do
    visit '/registrar/login'
    current_path.should == '/registrar/login'
  end

  fit 'should redirect to registrar login page' do
    visit '/registrar'
    current_path.should == '/registrar/login'
  end

  fit 'should redirect to registrar login page' do
    visit '/registrar/'
    current_path.should == '/registrar/login'
  end
end
