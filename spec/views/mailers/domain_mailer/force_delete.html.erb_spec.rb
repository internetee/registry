require 'rails_helper'

RSpec.describe 'mailers/domain_mailer/force_delete.html.erb' do
  let(:domain) { instance_spy(DomainPresenter) }
  let(:registrar) { instance_spy(RegistrarPresenter) }
  let(:registrant) { instance_spy(RegistrantPresenter) }
  let(:lang_count) { 3 }

  before :example do
    assign(:domain, domain)
    assign(:registrar, registrar)
    assign(:registrant, registrant)
  end

  it 'has domain name' do
    mention_count = 5 * lang_count
    expect(domain).to receive(:name).exactly(mention_count).times.and_return('test domain name')
    render
    expect(rendered).to have_text('test domain name', count: mention_count)
  end

  it 'has domain force delete date' do
    mention_count = 1 * lang_count
    expect(domain).to receive(:force_delete_date).exactly(mention_count).times.and_return('test domain force delete date')
    render
    expect(rendered).to have_text('test domain force delete date', count: mention_count)
  end

  it 'has registrar name' do
    mention_count = 2 * lang_count
    expect(registrar).to receive(:name).exactly(mention_count).times.and_return('test registrar name')
    render
    expect(rendered).to have_text('test registrar name', count: mention_count)
  end

  registrar_attributes = %i(
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

  it 'has registrant name' do
    mention_count = 1 * lang_count
    expect(registrant).to receive(:name).exactly(mention_count).times.and_return('test registrant name')
    render
    expect(rendered).to have_text('test registrant name', count: mention_count)
  end

  it 'has registrant ident' do
    mention_count = 2 * lang_count
    expect(registrant).to receive(:ident).exactly(mention_count).times.and_return('test registrant ident')
    render
    expect(rendered).to have_text('test registrant ident', count: mention_count)
  end
end
