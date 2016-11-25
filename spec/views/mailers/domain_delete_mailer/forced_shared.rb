require 'rails_helper'

RSpec.shared_examples 'domain delete mailer forced' do
  let(:domain) { instance_spy(DomainPresenter) }
  let(:registrar) { instance_spy(RegistrarPresenter) }
  let(:registrant) { instance_spy(RegistrantPresenter) }
  let(:lang_count) { 3 }

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

  it 'has registrar info in russian' do
    render
    expect(rendered).to have_text('test registrar russian')
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
end
