require 'rails_helper'

RSpec.describe 'mailers/domain_mailer/expiration.text.erb' do
  let(:domain) { instance_spy(DomainPresenter) }
  let(:registrar) { instance_spy(RegistrarPresenter) }
  let(:lang_count) { 3 }

  before :example do
    assign(:domain, domain)
    assign(:registrar, registrar)
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

  domain_attributes = %i(
    on_hold_date
    delete_date
    registrant_name
    admin_contact_names
    tech_contact_names
    nameserver_names
  )

  domain_attributes.each do |attr_name|
    it "has :#{attr_name}" do
      expect(domain).to receive(attr_name).exactly(lang_count).times.and_return(attr_name.to_s)
      render
      expect(rendered).to have_text(attr_name.to_s, count: lang_count)
    end
  end
end
