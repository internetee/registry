require 'rails_helper'

feature 'Domain', type: :feature do
  before :all do
    @user = Fabricate(:admin_user)
  end

  it 'should show index of domains' do
    Fabricate(:domain, name: 'testing.ee')
    sign_in @user
    visit admin_domains_url

    page.should have_content('testing.ee')
  end

  it 'should search domains by name' do
    d1 = Fabricate(:domain, name: 'abcde.ee')
    Fabricate(:domain, name: 'abcdee.ee')
    Fabricate(:domain, name: 'defgh.pri.ee')
    sign_in @user
    visit admin_domains_url

    page.should have_content('abcde.ee')
    page.should have_content('abcdee.ee')
    page.should have_content('defgh.pri.ee')

    fill_in 'q_name_matches', with: 'abcde.ee'
    find('.btn.btn-primary').click

    current_path.should == "/admin/domains/#{d1.id}"

    visit admin_domains_url
    fill_in 'q_name_matches', with: '.ee'
    find('.btn.btn-primary').click

    current_path.should == "/admin/domains"
    page.should have_content('abcde.ee')
    page.should have_content('abcdee.ee')
    page.should have_content('defgh.pri.ee')

    fill_in 'q_name_matches', with: 'abcd%.ee'
    find('.btn.btn-primary').click
    page.should have_content('abcde.ee')
    page.should have_content('abcdee.ee')
    page.should_not have_content('defgh.pri.ee')

    fill_in 'q_name_matches', with: 'abcd_.ee'
    find('.btn.btn-primary').click
    current_path.should == "/admin/domains/#{d1.id}"
  end
end
