require 'rails_helper'

RSpec.describe 'mailers/domain_mailer/pending_deleted.html.erb' do
  let(:domain) { instance_spy(DomainPresenter) }
  let(:registrar) { instance_spy(RegistrarPresenter) }
  let(:lang_count) { 2 }

  before :example do
    assign(:domain, domain)
    assign(:registrar, registrar)
    assign(:verification_url, 'test url')
  end

  it 'has domain name' do
    mention_count = 1 * lang_count
    expect(domain).to receive(:name).exactly(mention_count).times.and_return('test domain name')
    render
    expect(rendered).to have_text('test domain name', count: mention_count)
  end

  it 'has verification url' do
    mention_count = 1 * lang_count
    render
    expect(rendered).to have_text('test url', count: mention_count)
  end

  registrar_attributes = %i(
    name
    email
    phone
    url
  )

  registrar_attributes.each do |attr_name|
    it "has registrar #{attr_name}" do
      expect(registrar).to receive(attr_name).exactly(lang_count).times.and_return("test registrar #{attr_name}")
      render
      expect(rendered).to have_text("test registrar #{attr_name}", count: lang_count)
    end
  end
end
