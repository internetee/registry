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

  it 'should set domain to force delete' do
    d = Fabricate(:domain)
    sign_in @user
    visit admin_domains_url
    click_link d.name
    page.should have_content('ok')
    click_link 'Set force delete'
    page.should have_content('forceDelete')
    page.should have_content('serverRenewProhibited')
    page.should have_content('serverTransferProhibited')
    page.should have_content('serverUpdateProhibited')
    page.should have_content('serverManualInzone')
    page.should have_content('pendingDelete')

    click_link 'Edit statuses'
    click_button 'Save'
    page.should have_content('Failed to update domain')
    page.should have_content('Object status prohibits operation')

    click_link 'Back to domain'
    click_link 'Unset force delete'
    page.should_not have_content('forceDelete')
    page.should_not have_content('serverRenewProhibited')
    page.should_not have_content('serverTransferProhibited')
    page.should_not have_content('serverUpdateProhibited')
    page.should_not have_content('serverManualInzone')
    page.should_not have_content('pendingDelete')
    page.should have_content('ok')

    click_link 'Edit statuses'
    click_button 'Save'
    page.should have_content('Domain updated!')
  end
end
