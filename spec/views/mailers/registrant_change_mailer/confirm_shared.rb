require 'rails_helper'

RSpec.shared_examples 'registrant change mailer confirm' do
  let(:domain) { instance_spy(DomainPresenter) }
  let(:lang_count) { 2 }

  before :example do
    assign(:domain, domain)
    assign(:registrar, nil)
    assign(:new_registrant, nil)
    assign(:confirm_url, 'test confirm url')
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

  it 'has confirm url' do
    mention_count = 1 * lang_count
    render
    expect(rendered).to have_text('test confirm url', count: mention_count)
  end

  domain_attributes = %i(
    name
  )

  domain_attributes.each do |attr_name|
    it "has domain #{attr_name}" do
      expect(domain).to receive(attr_name).exactly(lang_count).times.and_return(attr_name.to_s)
      render
      expect(rendered).to have_text(attr_name.to_s, count: lang_count)
    end
  end
end
