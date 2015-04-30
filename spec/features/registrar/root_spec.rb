require 'rails_helper'

feature 'Root', type: :feature do
  before :all do
    Fabricate(:api_user)
  end

  it 'should redirect to registrar login page' do
    visit '/registrar/login'
    current_path.should == '/registrar/login'
  end

  it 'should redirect to registrar login page' do
    visit '/registrar'
    current_path.should == '/registrar/login'
  end

  it 'should redirect to registrar login page' do
    visit '/registrar/'
    current_path.should == '/registrar/login'
  end
end
