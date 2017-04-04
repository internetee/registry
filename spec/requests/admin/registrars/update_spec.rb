require 'rails_helper'

RSpec.describe 'admin registrar update' do
  before :example do
    sign_in_to_admin_area
  end

  it 'updates website' do
    registrar = create(:registrar, website: 'test')

    patch admin_registrar_path(registrar), registrar: attributes_for(:registrar, website: 'new-website')
    registrar.reload

    expect(registrar.website).to eq('new-website')
  end

  it 'updates email' do
    registrar = create(:registrar, email: 'test@test.com')

    patch admin_registrar_path(registrar), registrar: attributes_for(:registrar, email: 'new-test@test.com')
    registrar.reload

    expect(registrar.email).to eq('new-test@test.com')
  end

  it 'updates billing email' do
    registrar = create(:registrar, billing_email: 'test@test.com')

    patch admin_registrar_path(registrar), registrar: attributes_for(:registrar, billing_email: 'new-test@test.com')
    registrar.reload

    expect(registrar.billing_email).to eq('new-test@test.com')
  end

  it 'redirects to :show' do
    registrar = create(:registrar)

    patch admin_registrar_path(registrar), { registrar: attributes_for(:registrar) }

    expect(response).to redirect_to admin_registrar_path(registrar)
  end
end
