require 'rails_helper'

RSpec.describe 'registrar/contacts/_form' do
  let(:contact) { instance_spy(Depp::Contact) }

  before :example do
    without_partial_double_verification do
      allow(view).to receive(:f).and_return(ActionView::Helpers::FormBuilder.new(:contact, contact, view, {}))
    end

    assign(:contact, contact)

    stub_template 'registrar/shared/_error_messages.haml' => ''
    stub_template 'registrar/contacts/form/_general.html.haml' => ''
    stub_template 'registrar/contacts/form/_address.html.haml' => 'address info'
    stub_template 'registrar/contacts/form/_code.html.haml' => ''
    stub_template 'registrar/contacts/form/_legal_document.html.haml' => ''
  end

  context 'when address processing is enabled' do
    before do
      without_partial_double_verification do
        allow(view).to receive(:address_processing?).and_return(true)
      end
    end

    it 'has address' do
      render
      expect(rendered).to have_text('address info')
    end
  end

  context 'when address processing is disabled' do
    before do
      without_partial_double_verification do
        allow(view).to receive(:address_processing?).and_return(false)
      end
    end

    it 'has no address' do
      render
      expect(rendered).to_not have_text('address info')
    end
  end
end
