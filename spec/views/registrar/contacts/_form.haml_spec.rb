require 'rails_helper'

RSpec.describe 'registrar/contacts/_form' do
  let(:contact) { instance_spy(Depp::Contact) }

  before :example do
    allow(view).to receive(:f).and_return(ActionView::Helpers::FormBuilder.new(:contact, contact, view, {}))
    assign(:contact, contact)

    stub_template 'registrar/shared/_error_messages' => ''
    stub_template 'registrar/contacts/form_partials/_general' => ''
    stub_template 'registrar/contacts/form_partials/_address' => 'address info'
    stub_template 'registrar/contacts/form_partials/_code' => ''
    stub_template 'registrar/contacts/form_partials/_legal_document' => ''
  end

  context 'when address processing is enabled' do
    before do
      allow(view).to receive(:address_processing?).and_return(true)
    end

    it 'has address' do
      render
      expect(rendered).to have_text('address info')
    end
  end

  context 'when address processing is disabled' do
    before do
      allow(view).to receive(:address_processing?).and_return(false)
    end

    it 'has no address' do
      render
      expect(rendered).to_not have_text('address info')
    end
  end
end
