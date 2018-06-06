require 'rails_helper'

RSpec.describe 'registrar/domains/_form' do
  let(:domain) { instance_spy(Depp::Domain) }

  before :example do
    without_partial_double_verification do
      allow(view).to receive(:f).and_return(DefaultFormBuilder.new(:domain, domain, view, {}))
    end

    assign(:domain, domain)

    stub_template 'registrar/domains/form/_general.html.haml' => ''
    stub_template 'registrar/domains/form/_contacts.html.haml' => ''
    stub_template 'registrar/domains/form/_nameservers.html.haml' => ''
    stub_template 'registrar/domains/form/_dnskeys.html.haml' => ''
  end

  it 'has legal document' do
    render
    expect(rendered).to have_css('[name="domain[legal_document]"]')
  end
end
