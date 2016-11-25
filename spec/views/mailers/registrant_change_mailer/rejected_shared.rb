require 'rails_helper'

RSpec.shared_examples 'registrant change mailer rejected' do
  let(:domain) { instance_spy(DomainPresenter) }
  let(:registrar) { instance_spy(RegistrarPresenter) }
  let(:registrant) { instance_spy(RegistrantPresenter) }
  let(:lang_count) { 2 }

  before :example do
    assign(:domain, domain)
    assign(:registrar, registrar)
    assign(:registrant, registrant)
  end

  it 'has registrar info in estonian' do
    render
    expect(rendered).to have_text('test registrar estonian')
  end

  it 'has registrar info in english' do
    render
    expect(rendered).to have_text('test registrar english')
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

  registrant_attributes = %i(
    name
  )

  registrant_attributes.each do |attr_name|
    it "has registrant #{attr_name}" do
      expect(registrant).to receive(attr_name).exactly(lang_count).times.and_return("test registrant #{attr_name}")
      render
      expect(rendered).to have_text("test registrant #{attr_name}", count: lang_count)
    end
  end
end
