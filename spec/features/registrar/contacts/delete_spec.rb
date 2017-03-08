require 'rails_helper'

class FakeDeppContact
  include ActiveModel::Model

  def id
    'test'
  end

  def name
    'test'
  end

  def persisted?
    true
  end

  def password
    'test'
  end

  def delete
    true
  end
end

RSpec.feature 'Contact deletion in registrar area' do
  given!(:registrar) { create(:registrar) }
  given!(:contact) { create(:contact, registrar: registrar) }

  background do
    allow(Depp::Contact).to receive(:find_by_id).and_return(FakeDeppContact.new)
    allow(Depp::Contact).to receive(:new).and_return(FakeDeppContact.new)
    Setting.api_ip_whitelist_enabled = false
    Setting.registrar_ip_whitelist_enabled = false
    sign_in_to_registrar_area(user: create(:api_user_with_unlimited_balance, registrar: registrar))
  end

  it 'deletes contact' do
    visit registrar_contacts_url
    click_link_or_button 'Delete'
    confirm

    expect(page).to have_text('Destroyed')
  end

  private

  def confirm
    click_link_or_button 'Delete'
  end
end
