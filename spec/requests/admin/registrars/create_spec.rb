require 'rails_helper'

RSpec.describe 'admin registrar create' do
  subject(:registrar) { Registrar.first }

  before :example do
    sign_in_to_admin_area
  end

  it 'creates new registrar' do
    expect { post admin_registrars_path, registrar: attributes_for(:registrar) }
      .to change { Registrar.count }.from(0).to(1)
  end

  it 'saves website' do
    post admin_registrars_path, { registrar: attributes_for(:registrar, website: 'test') }
    expect(registrar.website).to eq('test')
  end

  it 'redirects to :show' do
    post admin_registrars_path, { registrar: attributes_for(:registrar) }
    expect(response).to redirect_to admin_registrar_path(registrar)
  end
end
