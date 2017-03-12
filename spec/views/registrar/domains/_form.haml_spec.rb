require 'rails_helper'

RSpec.describe 'registrar/domains/_form' do
  let(:domain) { instance_spy(Depp::Domain) }

  before :example do
    allow(view).to receive(:f).and_return(DefaultFormBuilder.new(:domain, domain, view, {}))
    assign(:domain, domain)

    stub_template 'registrar/domains/form/_general' => ''
    stub_template 'registrar/domains/form/_contacts' => ''
    stub_template 'registrar/domains/form/_nameservers' => ''
    stub_template 'registrar/domains/form/_dnskeys' => ''
  end

  it 'has legal document' do
    render
    expect(rendered).to have_css('[name="domain[legal_document]"]')
  end
end
