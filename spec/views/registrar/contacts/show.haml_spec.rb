require 'rails_helper'

RSpec.describe 'registrar/contacts/show' do
  let(:contact) { instance_spy(Depp::Contact, id: 1, name: 'test') }

  before do
    assign(:contact, contact)
    stub_template 'shared/_title.html.haml' => ''
    stub_template 'registrar/contacts/partials/_general.html.haml' => ''
    stub_template 'registrar/contacts/partials/_statuses.html.haml' => ''
    stub_template 'registrar/contacts/partials/_domains.html.haml' => ''
    stub_template 'registrar/contacts/partials/_address.html.haml' => 'address info'
  end

  context 'when address processing is enabled' do
    before do
      allow(Contact).to receive(:address_processing?).and_return(true)
    end

    it 'has address' do
      render
      expect(rendered).to have_text('address info')
    end
  end

  context 'when address processing is disabled' do
    before do
      allow(Contact).to receive(:address_processing?).and_return(false)
    end

    it 'has no address' do
      render
      expect(rendered).to_not have_text('address info')
    end
  end
end
