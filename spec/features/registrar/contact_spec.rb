require 'rails_helper'

feature 'Contact', type: :feature do
  before :all do
    @user = Fabricate(:api_user)
  end

  context 'as unknown user' do
    it 'should redirect to sign in page' do
      visit '/registrar/contacts'
      current_path.should == '/registrar/login'
      page.should have_text('You need to sign in or sign up')
    end
  end

  context 'as signed in user' do
    before do
      registrar_sign_in
    end

    it 'should navigate to the contact index page' do
      click_link 'Contacts'
      current_path.should == '/registrar/contacts'
    end

    it 'should get contact index page' do
      visit '/registrar/contacts'
      current_path.should == '/registrar/contacts'
    end

    context 'manage contact' do
      it 'should navigate to new page' do
        click_link 'Contacts'
        click_link 'New'

        current_path.should == '/registrar/contacts/new'
      end

      it 'should get new page' do
        visit '/registrar/contacts/new'
        current_path.should == '/registrar/contacts/new'
      end

      it 'should get warnings' do
        visit '/registrar/contacts/new'
        current_path.should == '/registrar/contacts/new'

        fill_in 'depp_contact_ident',  with: ''
        fill_in 'depp_contact_name',   with: 'Business Name Ltd'
        fill_in 'depp_contact_email',  with: 'example@example.com'
        fill_in 'depp_contact_street', with: 'Example street 12'
        fill_in 'depp_contact_city',   with: 'Example City'
        fill_in 'depp_contact_zip',    with: '123456'
        fill_in 'depp_contact_phone',  with: '+372.12345678'
        click_button 'Create'

        current_path.should == '/registrar/contacts'
        page.should have_text('Required parameter missing')
      end

      def create_contact
        visit '/registrar/contacts/new'
        current_path.should == '/registrar/contacts/new'

        fill_in 'depp_contact_ident',  with: 'org-ident'
        fill_in 'depp_contact_name',   with: 'Business Name Ltd'
        fill_in 'depp_contact_email',  with: 'example@example.com'
        fill_in 'depp_contact_street', with: 'Example street 12'
        fill_in 'depp_contact_city',   with: 'Example City'
        fill_in 'depp_contact_zip',    with: '123456'
        fill_in 'depp_contact_phone',  with: '+372.12345678'
        click_button 'Create'

        page.should have_text('Business Name Ltd')
        page.should have_text('org-ident [EE org]')
      end

      it 'should create new contact with success' do
        create_contact
      end

      it 'should edit sucessfully' do
        create_contact
        click_link 'Edit'

        current_path.should match(/edit/)
        fill_in 'depp_contact_name', with: 'Edited Business Name Ltd'
        click_button 'Save'

        page.should have_text('Edited Business Name Ltd')
      end
    end
  end
end
