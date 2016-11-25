require 'rails_helper'

RSpec.shared_examples 'registrant change mailer notice' do
  let(:domain) { instance_spy(DomainPresenter) }
  let(:registrar) { instance_spy(RegistrarPresenter) }
  let(:registrant) { instance_spy(RegistrantPresenter) }
  let(:lang_count) { 2 }

  before :example do
    assign(:domain, domain)
    assign(:registrar, registrar)
    assign(:current_registrant, registrant)
    assign(:new_registrant, registrant)
  end

  it 'has registrar info in estonian' do
    render
    expect(rendered).to have_text('test registrar estonian')
  end

  it 'has registrar info in english' do
    render
    expect(rendered).to have_text('test registrar english')
  end

  it 'has new registrant info in estonian' do
    render
    expect(rendered).to have_text('test new registrant estonian')
  end

  it 'has new registrant info in english' do
    render
    expect(rendered).to have_text('test new registrant english')
  end

  domain_attributes = %i(
    name
  )

  domain_attributes.each do |attr_name|
    it "has domain #{attr_name}" do
      expect(domain).to receive(attr_name).exactly(lang_count).times.and_return("test domain #{attr_name}")
      render
      expect(rendered).to have_text("test domain #{attr_name}", count: lang_count)
    end
  end
end
