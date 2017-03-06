require 'rails_helper'

RSpec.describe 'registrar/contacts/form/_legal_document' do
  let(:contact) { instance_spy(Depp::Contact) }

  before :example do
    allow(view).to receive(:f).and_return(DefaultFormBuilder.new(:depp_contact, contact, view, {}))
    assign(:contact, contact)
  end

  it 'has legal document' do
    render
    expect(rendered).to have_css('[name="depp_contact[legal_document]"]')
  end
end
