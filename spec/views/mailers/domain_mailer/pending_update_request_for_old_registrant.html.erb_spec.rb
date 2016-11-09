require 'rails_helper'

RSpec.describe 'mailers/domain_mailer/pending_update_request_for_old_registrant.html.erb' do
  let(:domain) { instance_spy(DomainPresenter) }
  let(:registrar) { instance_spy(RegistrarPresenter) }
  let(:registrant) { instance_spy(RegistrantPresenter) }
  let(:lang_count) { 2 }

  before :example do
    assign(:domain, domain)
    assign(:registrar, registrar)
    assign(:registrant, registrant)
    assign(:verification_url, 'test url')
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

  domain_attributes = %i(
    name
  )

  domain_attributes.each do |attr_name|
    it "has :#{attr_name}" do
      expect(domain).to receive(attr_name).exactly(lang_count).times.and_return(attr_name.to_s)
      render
      expect(rendered).to have_text(attr_name.to_s, count: lang_count)
    end
  end

  registrant_attributes = %i(
    name
    ident
    street
    city
    country
  )

  registrant_attributes.each do |attr_name|
    it "has registrant #{attr_name}" do
      expect(registrant).to receive(attr_name).exactly(lang_count).times.and_return("test registrant #{attr_name}")
      render
      expect(rendered).to have_text("test registrant #{attr_name}", count: lang_count)
    end
  end
end
